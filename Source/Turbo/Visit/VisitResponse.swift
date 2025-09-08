import Foundation

public struct VisitResponse: Codable {
    public let statusCode: Int
    public let redirected: Bool
    public let responseHTML: String?

    public init(statusCode: Int, redirected: Bool, responseHTML: String? = nil) {
        self.statusCode = statusCode
        self.redirected = redirected
        self.responseHTML = responseHTML
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
        self.redirected = try container.decodeIfPresent(Bool.self, forKey: .redirected) ?? false
        self.responseHTML = try container.decodeIfPresent(String.self, forKey: .responseHTML)
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
