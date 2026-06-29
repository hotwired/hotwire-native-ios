import Foundation

enum RedirectHandlerError: LocalizedError {
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
            return "Redirect resolution failed: \(error.localizedDescription)"
        case .responseValidationFailed(let reason):
            switch reason {
            case .missingURL:
                return "Redirect resolution failed: missing URL"
            case .invalidResponse:
                return "Redirect resolution response invalid"
            }
        }
    }
}

struct RedirectHandler {
    enum Result {
        case noRedirect
        case sameOriginRedirect(URL)
        case crossOriginRedirect(URL)
    }

    func resolve(
        location: URL,
        timeout: TimeInterval = Hotwire.config.redirectResolutionTimeout
    ) async throws -> Result {
        do {
            var request = URLRequest(url: location)
            request.timeoutInterval = timeout
            let (_, response) = try await URLSession.shared.data(for: request)
            let httpResponse = try validateResponse(response)

            guard let responseUrl = httpResponse.url else {
                throw RedirectHandlerError.responseValidationFailed(reason: .missingURL)
            }

            let isRedirect = location != responseUrl
            let redirectIsCrossOrigin = isRedirect && location.host != responseUrl.host

            guard isRedirect else {
                return .noRedirect
            }

            if redirectIsCrossOrigin {
                return .crossOriginRedirect(responseUrl)
            }

            return .sameOriginRedirect(responseUrl)
        } catch let error as RedirectHandlerError {
            throw error
        } catch {
            throw RedirectHandlerError.requestFailed(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RedirectHandlerError.responseValidationFailed(reason: .invalidResponse)
        }

        return httpResponse
    }
}
