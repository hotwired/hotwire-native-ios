import Foundation

/// Errors representing HTTP status codes received from the server.
public enum HTTPError: LocalizedError, Equatable, Sendable {
    case client(ClientError)
    case server(ServerError)

    /// The HTTP status code for this error.
    public var statusCode: Int {
        switch self {
        case .client(let error):
            return error.statusCode
        case .server(let error):
            return error.statusCode
        }
    }

    public var errorDescription: String? {
        switch self {
        case .client(let error):
            return error.errorDescription
        case .server(let error):
            return error.errorDescription
        }
    }

    /// Creates an HTTPError from an HTTP status code.
    /// Returns `nil` for status codes outside the 400-599 error range.
    public init?(statusCode: Int) {
        if (400...499).contains(statusCode) {
            self = .client(ClientError(statusCode: statusCode))
        } else if (500...599).contains(statusCode) {
            self = .server(ServerError(statusCode: statusCode))
        } else {
            return nil
        }
    }
}

// MARK: - Client Errors (4xx)

extension HTTPError {
    /// Errors representing HTTP client errors in the 400-499 range.
    public enum ClientError: LocalizedError, Equatable, Sendable {
        case badRequest
        case unauthorized
        case paymentRequired
        case forbidden
        case notFound
        case methodNotAllowed
        case notAcceptable
        case proxyAuthenticationRequired
        case requestTimeout
        case conflict
        case misdirectedRequest
        case unprocessableEntity
        case preconditionRequired
        case tooManyRequests
        case other(statusCode: Int)

        public var statusCode: Int {
            switch self {
            case .badRequest: return 400
            case .unauthorized: return 401
            case .paymentRequired: return 402
            case .forbidden: return 403
            case .notFound: return 404
            case .methodNotAllowed: return 405
            case .notAcceptable: return 406
            case .proxyAuthenticationRequired: return 407
            case .requestTimeout: return 408
            case .conflict: return 409
            case .misdirectedRequest: return 421
            case .unprocessableEntity: return 422
            case .preconditionRequired: return 428
            case .tooManyRequests: return 429
            case .other(let code): return code
            }
        }

        public var errorDescription: String? {
            switch self {
            case .badRequest: return "Bad Request"
            case .unauthorized: return "Unauthorized"
            case .paymentRequired: return "Payment Required"
            case .forbidden: return "Forbidden"
            case .notFound: return "Not Found"
            case .methodNotAllowed: return "Method Not Allowed"
            case .notAcceptable: return "Not Acceptable"
            case .proxyAuthenticationRequired: return "Proxy Authentication Required"
            case .requestTimeout: return "Request Timeout"
            case .conflict: return "Conflict"
            case .misdirectedRequest: return "Misdirected Request"
            case .unprocessableEntity: return "Unprocessable Entity"
            case .preconditionRequired: return "Precondition Required"
            case .tooManyRequests: return "Too Many Requests"
            case .other(let code): return "Client Error (\(code))"
            }
        }

        public init(statusCode: Int) {
            switch statusCode {
            case 400: self = .badRequest
            case 401: self = .unauthorized
            case 402: self = .paymentRequired
            case 403: self = .forbidden
            case 404: self = .notFound
            case 405: self = .methodNotAllowed
            case 406: self = .notAcceptable
            case 407: self = .proxyAuthenticationRequired
            case 408: self = .requestTimeout
            case 409: self = .conflict
            case 421: self = .misdirectedRequest
            case 422: self = .unprocessableEntity
            case 428: self = .preconditionRequired
            case 429: self = .tooManyRequests
            default: self = .other(statusCode: statusCode)
            }
        }
    }
}

// MARK: - Server Errors (5xx)

extension HTTPError {
    /// Errors representing HTTP server errors in the 500-599 range.
    public enum ServerError: LocalizedError, Equatable, Sendable {
        case internalServerError
        case notImplemented
        case badGateway
        case serviceUnavailable
        case gatewayTimeout
        case httpVersionNotSupported
        case other(statusCode: Int)

        public var statusCode: Int {
            switch self {
            case .internalServerError: return 500
            case .notImplemented: return 501
            case .badGateway: return 502
            case .serviceUnavailable: return 503
            case .gatewayTimeout: return 504
            case .httpVersionNotSupported: return 505
            case .other(let code): return code
            }
        }

        public var errorDescription: String? {
            switch self {
            case .internalServerError: return "Internal Server Error"
            case .notImplemented: return "Not Implemented"
            case .badGateway: return "Bad Gateway"
            case .serviceUnavailable: return "Service Unavailable"
            case .gatewayTimeout: return "Gateway Timeout"
            case .httpVersionNotSupported: return "HTTP Version Not Supported"
            case .other(let code): return "Server Error (\(code))"
            }
        }

        public init(statusCode: Int) {
            switch statusCode {
            case 500: self = .internalServerError
            case 501: self = .notImplemented
            case 502: self = .badGateway
            case 503: self = .serviceUnavailable
            case 504: self = .gatewayTimeout
            case 505: self = .httpVersionNotSupported
            default: self = .other(statusCode: statusCode)
            }
        }
    }
}
