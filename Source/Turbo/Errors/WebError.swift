import Foundation

/// Errors representing network/connection errors received when attempting to load a page.
/// Wraps URLError to provide full access to iOS error
public struct WebError: LocalizedError, Equatable, Sendable {
    enum Source: Equatable, Sendable {
        case urlError(URLError)
        case turboError(TurboError)
        case raw(errorCode: Int, message: String)
    }

    let source: Source

    /// The underlying URLError, if available.
    /// This is nil when the error originates from Turbo.js status codes rather than iOS networking.
    public var urlError: URLError? {
        if case .urlError(let urlError) = source {
            return urlError
        }
        return nil
    }

    /// The error code (from URLError, Turbo.js status code, or raw network error code).
    public var errorCode: Int {
        switch source {
        case .urlError(let urlError):
            return urlError.code.rawValue
        case .turboError(let error):
            return error.statusCode
        case .raw(let errorCode, _):
            return errorCode
        }
    }

    /// A description of the error.
    public var message: String {
        switch source {
        case .urlError(let urlError):
            return urlError.localizedDescription
        case .turboError(let error):
            return error.localizedDescription
        case .raw(_, let message):
            return message
        }
    }

    // MARK: - Helper Properties

    /// Whether the device appears to be offline or has lost connection.
    public var isOffline: Bool {
        guard let code = urlError?.code else { return false }
        return [.notConnectedToInternet, .networkConnectionLost].contains(code)
    }

    /// Whether the request timed out.
    public var isTimeout: Bool {
        switch source {
        case .urlError(let urlError):
            return urlError.code == .timedOut
        case .turboError(.timeout):
            return true
        case .turboError:
            return false
        case .raw:
            return errorCode == URLError.Code.timedOut.rawValue
        }
    }

    /// Whether the server could not be reached.
    public var isConnectionError: Bool {
        guard let code = urlError?.code else { return false }
        return [.cannotFindHost, .cannotConnectToHost, .dnsLookupFailed].contains(code)
    }

    /// Whether this is an SSL/TLS error.
    public var isSSLError: Bool {
        guard let code = urlError?.code else { return false }
        return [
            .secureConnectionFailed,
            .serverCertificateHasBadDate,
            .serverCertificateUntrusted,
            .serverCertificateHasUnknownRoot,
            .serverCertificateNotYetValid,
            .clientCertificateRejected,
            .clientCertificateRequired
        ].contains(code)
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        if isConnectionError || isOffline {
            return "Could not connect to the server."
        } else if isTimeout {
            return "The request timed out."
        } else if isSSLError {
            return "A secure connection could not be established."
        } else if urlError?.code == .httpTooManyRedirects {
            return "Too many redirects occurred."
        } else if urlError?.code == .badURL {
            return "The URL is invalid."
        } else if let urlError {
            // Fall back to system's localized description for unhandled URLError codes
            // (e.g., ATS, background-session, caching errors)
            return urlError.localizedDescription
        } else {
            return message
        }
    }

    // MARK: - Initializers

    public init(urlError: URLError) {
        source = .urlError(urlError)
    }

    public init(errorCode: Int, message: String?) {
        source = .raw(errorCode: errorCode, message: message ?? "Network Error")
    }

    init(turboError: TurboError) {
        source = .turboError(turboError)
    }

    // MARK: - Factory Methods

    /// Creates a WebError from any Error (attempts to extract URLError if possible).
    public init(_ error: Error) {
        if let urlError = error as? URLError {
            self.init(urlError: urlError)
        } else {
            self.init(errorCode: (error as NSError).code, message: error.localizedDescription)
        }
    }
}
