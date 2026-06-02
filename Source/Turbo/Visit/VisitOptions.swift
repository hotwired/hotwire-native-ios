import Foundation

public struct VisitOptions: Codable, JSONCodable {
    public let action: VisitAction
    public let response: VisitResponse?
    public let shouldCacheSnapshot: Bool?

    public init(action: VisitAction = .advance,
                response: VisitResponse? = nil,
                shouldCacheSnapshot: Bool? = nil) {
        self.action = action
        self.response = response
        self.shouldCacheSnapshot = shouldCacheSnapshot
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decodeIfPresent(VisitAction.self, forKey: .action) ?? .advance
        self.response = try container.decodeIfPresent(VisitResponse.self, forKey: .response)
        self.shouldCacheSnapshot = try container.decodeIfPresent(Bool.self, forKey: .shouldCacheSnapshot)
    }
}
