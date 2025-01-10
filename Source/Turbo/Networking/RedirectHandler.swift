import Foundation

enum RedirectHandlerError: Error {
    case requestFailed(Error)
    case responseValidationFailed(reason: ResponseValidationFailureReason)

    /// The underlying reason the `.responseValidationFailed` error occurred.
    public enum ResponseValidationFailureReason: Sendable {
        case missingURL
        case invalidResponse
        case unacceptableStatusCode(code: Int)
    }
}

struct RedirectHandler {
    enum Result {
        case noRedirect
        case sameOriginRedirect(URL)
        case crossOriginRedirect(URL)
    }

    func resolve(location: URL) async throws -> Result {
        do {
            let request = URLRequest(url: location)
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

        guard httpResponse.isSuccessful else {
            throw RedirectHandlerError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode))
        }

        return httpResponse
    }
}

extension HTTPURLResponse {
    public var isSuccessful: Bool {
        (200...299).contains(statusCode)
    }
}
