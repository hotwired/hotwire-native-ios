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
        case redirect(URL)
        case crossOriginRedirect(URL)
    }

    func resolve(location: URL) async throws -> Result {
        do {
            let request = URLRequest(url: location)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RedirectHandlerError.responseValidationFailed(reason: .invalidResponse)
            }

            guard httpResponse.isSuccessful else {
                throw RedirectHandlerError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode))
            }

            guard let responseUrl = response.url else {
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

            return .redirect(responseUrl)
        } catch {
            throw RedirectHandlerError.requestFailed(error)
        }
    }
}

extension HTTPURLResponse {
    public var isSuccessful: Bool {
        switch statusCode {
        case 200 ... 299:
            return true
        default:
            return false
        }
    }
}
