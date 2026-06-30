import Foundation

enum JSFetchRecoveryError: LocalizedError {
    case requestFailed(Error)
    case responseValidationFailed(reason: ResponseValidationFailureReason)

    /// The underlying reason the `.responseValidationFailed` error occurred.
    enum ResponseValidationFailureReason: Sendable {
        case missingURL
        case invalidResponse
    }

    var errorDescription: String? {
        switch self {
        case .requestFailed(let error):
            return "Failed to recover js fetch: \(error.localizedDescription)"
        case .responseValidationFailed(let reason):
            switch reason {
            case .missingURL:
                return "Failed to validate js fetch resolution response: missing URL"
            case .invalidResponse:
                return "Failed to validate js fetch resolution response: response invalid"
            }
        }
    }
}

struct JSFetchRecoveryHandler {
    enum Result {
        case noRedirect
        case sameOriginRedirect(URL)
        case crossOriginRedirect(URL)
    }

    func resolve(
        location: URL,
        timeout: TimeInterval = Hotwire.config.redirectResolutionTimeout
    ) async throws -> Result {
        logger.debug("[JSFetchRecoveryHandler] resolve: \(location.absoluteString)")
        do {
            var request = URLRequest(url: location)
            request.timeoutInterval = timeout
            let (_, response) = try await URLSession.shared.data(for: request)
            let httpResponse = try validateResponse(response)

            guard let responseUrl = httpResponse.url else {
                throw JSFetchRecoveryError.responseValidationFailed(reason: .missingURL)
            }

            let isRedirect = location != responseUrl
            let redirectIsCrossOrigin = isRedirect && location.host != responseUrl.host

            guard isRedirect else {
                logger.debug("[JSFetchRecoveryHandler] no redirect, status: \(httpResponse.statusCode)")
                return .noRedirect
            }

            if redirectIsCrossOrigin {
                logger.debug("[JSFetchRecoveryHandler] cross-origin redirect to \(responseUrl.absoluteString)")
                return .crossOriginRedirect(responseUrl)
            }

            logger.debug("[JSFetchRecoveryHandler] same-origin redirect to \(responseUrl.absoluteString)")
            return .sameOriginRedirect(responseUrl)
        } catch let error as JSFetchRecoveryError {
            throw error
        } catch {
            throw JSFetchRecoveryError.requestFailed(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JSFetchRecoveryError.responseValidationFailed(reason: .invalidResponse)
        }

        return httpResponse
    }
}
