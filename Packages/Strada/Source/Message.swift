import Foundation

/// A `Message` is the structure sent back and forth over the bridge
/// to enable communication between native and web apps
public struct Message: Equatable {
    /// A unique identifier for this message. When you reply to the web with
    /// a message, this identifier is used to find its previously sent message.
    public let id: String
    
    /// The component the message is sent from (e.g. - "form", "page", etc)
    public let component: String
    
    /// The event that this message is about: "submit", "display", "send"
    public let event: String
    
    /// The metadata associated with the message, which includes its url.
    public let metadata: Metadata?
    
    /// Data, represented in a json object string, to send along with the message.
    /// For a "page" component, this might be `{"title": "Page Title"}`.
    public let jsonData: String
    
    public init(id: String,
                component: String,
                event: String,
                metadata: Metadata?,
                jsonData: String) {
        self.id = id
        self.component = component
        self.event = event
        self.metadata = metadata
        self.jsonData = jsonData
    }
}

extension Message {
    /// Replaces the existing `Message`'s data with passed-in data and event.
    /// - Parameters:
    ///   - updatedEvent: The updated event of this message. If omitted, the existing event is used.
    ///   - updatedData: The updated data of this message. If omitted, the existing data is used.
    /// - Returns: A new `Message` with the provided data.
    public func replacing(event updatedEvent: String? = nil,
                          jsonData updatedData: String? = nil) -> Message {
        Message(id: id,
                component: component,
                event: updatedEvent ?? event,
                metadata: metadata,
                jsonData: updatedData ?? jsonData)
    }
    
    /// Replaces the existing `Message`'s data with passed-in `Encodable` object and event.
    /// - Parameters:
    ///   - updatedEvent: The updated event of this message. If omitted, the existing event is used.
    ///   - data: An instance conforming to `Encodable` to be included as data in the message.
    /// - Returns: A new `Message` with the provided data.
    public func replacing<T: Encodable>(event updatedEvent: String? = nil,
                                        data: T) -> Message {
        let updatedData: String?
        do {
            let jsonData = try Strada.config.jsonEncoder.encode(data)
            updatedData = String(data: jsonData, encoding: .utf8)
        } catch {
            logger.error("Error encoding codable object: \(String(describing: data)) -> \(error)")
            updatedData = nil
        }
        
        return replacing(event: updatedEvent, jsonData: updatedData)
    }
    
    /// Returns a value of the type you specify, decoded from the `jsonData`.
    /// - Returns: A value of the specified type, if the decoder can parse the data, otherwise nil.
    public func data<T: Decodable>() -> T? {
        guard let data = jsonData.data(using: .utf8) else {
            logger.error("Error converting json string to data: \(jsonData)")
            return nil
        }
        
        do {
            let decoder = Strada.config.jsonDecoder
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Error decoding json: \(jsonData) -> \(error)")
            return nil
        }
    }
}

extension Message {
    public struct Metadata: Equatable {
        public let url: String
        
        public init(url: String) {
            self.url = url
        }
    }
}
