import Foundation

/// Errors representing when turbo.js or the native adapter fails to load on a page.
public enum LoadError: LocalizedError, Equatable, Sendable {
    /// Turbo.js is not present on the page.
    case notPresent

    /// Turbo.js is present but not ready/initialized.
    case notReady

    /// The server returned an invalid content type (non-HTML response).
    case contentTypeMismatch

    /// The server returned a malformed or unexpected response.
    case invalidResponse

    public var title: String {
        switch self {
        case .notPresent: return "Turbo Not Present"
        case .notReady: return "Turbo Not Ready"
        case .contentTypeMismatch: return "Content Type Mismatch"
        case .invalidResponse: return "Invalid Response"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .notPresent:
            return "The page could not be loaded because Turbo is not present."
        case .notReady:
            return "The page could not be loaded because Turbo is not ready."
        case .contentTypeMismatch:
            return "The server returned an invalid content type."
        case .invalidResponse:
            return "The server returned an invalid response."
        }
    }
}
