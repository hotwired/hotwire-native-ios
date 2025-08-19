import Foundation

public struct VisitResponse: Codable {
    public let statusCode: Int
    public let redirected: Bool
    public let responseHTML: String?

    public init(statusCode: Int, redirected: Int = 0, responseHTML: String? = nil) {
        self.statusCode = statusCode
        self.redirected = redirected == 1
        self.responseHTML = responseHTML
    }

    public var isSuccessful: Bool {
        switch statusCode {
        case 200 ... 299:
            return true
        default:
            return false
        }
    }
}
