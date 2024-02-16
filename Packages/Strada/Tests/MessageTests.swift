import XCTest
@testable import Strada

class MessageTests: XCTestCase {
    
    private let metadata = Message.Metadata(url: "https://37signals.com")
    
    override func setUp() async throws {
        Strada.config.jsonEncoder = JSONEncoder()
        Strada.config.jsonDecoder = JSONDecoder()
    }
    
    // MARK: replacing(event:, jsonData:)
    
    func testReplacingWithNewEventAndData() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let newEvent = "disconnect"
        let newData = "{}"
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let newMessage = message.replacing(event: newEvent, jsonData: newData)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, newEvent)
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, newData)
    }
    
    func testReplacingByChangingDataWithoutChangingEvent() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        let newData = """
        {"title":"Page-title""}
        """
        let newMessage = message.replacing(jsonData: newData)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, "connect")
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, newData)
    }
    
    func testReplacingByChangingEventWithoutChangingData() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        let newEvent = "disconnect"
        let newMessage = message.replacing(event: newEvent)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, newEvent)
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, jsonData)
    }
    
    func testReplacingWithoutChangingEventAndData() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let newMessage = message.replacing()
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, "connect")
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, jsonData)
    }
    
    // MARK: replacing(event:, data:)
    
    func testReplacingWithNewEventAndEncodable() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let newEvent = "disconnect"
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: "{}")
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        let newJsonData = "{\"title\":\"hey\",\"subtitle\":\"\",\"actionName\":\"tap\"}"
        
        let newMessage = message.replacing(event: newEvent, data: messageData)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, newEvent)
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, newJsonData)
    }
    
    func testReplacingByChangingEncodableWithoutChangingEvent() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: "{\"title\":\"Page-title\"}")
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        let newJsonData = "{\"title\":\"hey\",\"subtitle\":\"\",\"actionName\":\"tap\"}"
        
        let newMessage = message.replacing(data: messageData)

        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, "connect")
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, newJsonData)
    }
    
    // MARK: Decoding
    
    func test_decodingWithDefaultDecoder() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle", "actionName": "go"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let pageData = MessageData(title: "Page-title",
                                   subtitle: "Page-subtitle",
                                   actionName: "go")
        
        let decodedMessageData: MessageData? = message.data()
        
        XCTAssertEqual(decodedMessageData, pageData)
    }
    
    func test_decodingWithCustomDecoder() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        Strada.config.jsonDecoder = decoder
        
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle", "action_name": "go"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let pageData = MessageData(title: "Page-title",
                                   subtitle: "Page-subtitle",
                                   actionName: "go")
        
        let decodedMessageData: MessageData? = message.data()
        
        XCTAssertEqual(decodedMessageData, pageData)
    }
    
    // MARK: Custom encoding
    
    func test_encodingWithCustomEncoder() throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        Strada.config.jsonEncoder = encoder
        
        let messageData = MessageData(title: "Page-title",
                                   subtitle: "Page-subtitle",
                                   actionName: "go")

        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle","action_name":"go"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let newMessage = message.replacing(data: messageData)
        
        XCTAssertEqual(message.id, newMessage.id)
        XCTAssertEqual(message.event, newMessage.event)
        XCTAssertEqual(message.metadata, newMessage.metadata)

        // JSON as a string might have keys in a different order. Parse values to ensure equality.
        let newMessageData = try XCTUnwrap(message.jsonData.jsonObject() as? [String: String])
        XCTAssertEqual(newMessageData.keys.count, 3)
        XCTAssertEqual(newMessageData["title"], "Page-title")
        XCTAssertEqual(newMessageData["subtitle"], "Page-subtitle")
        XCTAssertEqual(newMessageData["action_name"], "go")
    }
}
