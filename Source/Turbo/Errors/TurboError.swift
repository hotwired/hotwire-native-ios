import Foundation

/// Semantic errors reported by Turbo.js for load failures that are not HTTP response codes.
enum TurboError: LocalizedError, Equatable, Sendable {
    case networkFailure
    case timeout
    case contentTypeMismatch
    case unknownStatusCode(Int)

    init?(statusCode: Int) {
        switch statusCode {
        case 0:
            self = .networkFailure
        case -1:
            self = .timeout
        case -2:
            self = .contentTypeMismatch
        case ..<0:
            self = .unknownStatusCode(statusCode)
        default:
            return nil
        }
    }

    var statusCode: Int {
        switch self {
        case .networkFailure:
            return 0
        case .timeout:
            return -1
        case .contentTypeMismatch:
            return -2
        case .unknownStatusCode(let statusCode):
            return statusCode
        }
    }

    public var errorDescription: String? {
        switch self {
        case .networkFailure:
            return "Network failure"
        case .timeout:
            return "Timeout"
        case .contentTypeMismatch, .unknownStatusCode:
            return "Network error"
        }
    }
}
