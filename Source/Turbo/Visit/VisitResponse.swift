import Foundation

public struct VisitResponse: Codable {
    public let statusCode: Int
    public let responseHTML: String?
    public let redirected: Bool

    public init(statusCode: Int, responseHTML: String? = nil, redirected: Bool = false) {
        self.statusCode = statusCode
        self.responseHTML = responseHTML
        self.redirected = redirected
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
        self.responseHTML = try container.decodeIfPresent(String.self, forKey: .responseHTML)
        if let redirected = try? container.decode(Bool.self, forKey: .redirected) {
            self.redirected = redirected
        } else {
            redirected = false
        }
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
