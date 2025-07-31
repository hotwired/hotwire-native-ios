import Foundation
import WebKit

typealias InternalMessageData = [String: AnyHashable]

struct InternalMessage {
    let id: String
    let component: String
    let event: String
    let data: InternalMessageData
    
    init(id: String,
         component: String,
         event: String,
         data: InternalMessageData)
    {
        self.id = id
        self.component = component
        self.event = event
        self.data = data
    }
    
    init(from message: Message) {
        let jsonObject = message.jsonData.jsonObject()
        let data = InternalMessage.safeExtractData(from: jsonObject)

        self.init(id: message.id,
                  component: message.component,
                  event: message.event,
                  data: data)
    }
    
    init?(scriptMessage: WKScriptMessage) {
        guard let message = scriptMessage.body as? [String: AnyHashable] else {
            logger.warning("Script message is missing body: \(scriptMessage)")
            return nil
        }
        
        self.init(jsonObject: message)
    }
    
    init?(jsonObject: [String: AnyHashable]) {
        guard let id = jsonObject[CodingKeys.id.rawValue] as? String,
              let component = jsonObject[CodingKeys.component.rawValue] as? String,
              let event = jsonObject[CodingKeys.event.rawValue] as? String
        else {
            logger.error("Error parsing script message: \(jsonObject)")
            return nil
        }
        
        let data = InternalMessage.safeExtractData(from: jsonObject[CodingKeys.data.rawValue])
        
        self.init(id: id,
                  component: component,
                  event: event,
                  data: data)
    }
    
    // MARK: Utils
    
    func toMessage() -> Message {
        return Message(id: id,
                       component: component,
                       event: event,
                       metadata: metadata(),
                       jsonData: dataAsJSONString() ?? "{}")
    }
    
    /// Used internally for converting the message into a JSON-friendly format for sending over the bridge
    func toJSON() -> [String: AnyHashable] {
        [
            CodingKeys.id.rawValue: id,
            CodingKeys.component.rawValue: component,
            CodingKeys.event.rawValue: event,
            CodingKeys.data.rawValue: data
        ]
    }
    
    // MARK: Private
    
    private func metadata() -> Message.Metadata? {
        guard let jsonData = data.jsonData(),
              let internalMetadata: InternalMessage.DataMetadata = try? jsonData.decoded() else { return nil }
        
        return Message.Metadata(url: internalMetadata.metadata.url)
    }

    private static func safeExtractData(from value: Any?) -> InternalMessageData {
        guard let value = value else {
            return [:]
        }

        if let dictionaryData = value as? InternalMessageData {
            return dictionaryData
        }

        logger.warning("[InternalMessage] InternalMessageData expects a dictionary, but received \(type(of: value)). Data will be ignored.)")
        return [:]
    }

    private func dataAsJSONString() -> String? {
        guard let jsonData = data.jsonData() else { return nil }
        
        return String(data: jsonData, encoding: .utf8)
    }
}

extension InternalMessage {
    struct DataMetadata: Codable {
        let metadata: InternalMessage.Metadata
    }

    struct Metadata: Codable {
        let url: String
    }

    enum CodingKeys: String {
        case id
        case component
        case event
        case data
    }
}
