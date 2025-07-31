@testable import HotwireNative
import WebKit
import XCTest

class InternalMessageTests: XCTestCase {
    private let json = """
    {
        "id":"1",
        "component":"page",
        "event":"connect",
        "data":{
            "metadata":{
                "url":"https://37signals.com"
            },
            "title":"Page-title",
            "subtitle":"Page-subtitle",
            "actions": [
                "one",
                "two",
                "three"
            ]
        }
    }
    """
    func testToMessage() {
        let messageJsonData = """
        {
           "metadata":{
              "url":"https://37signals.com"
           },
           "title":"Page-title",
           "subtitle":"Page-subtitle",
           "actions":[
              "one",
              "two",
              "three"
           ]
        }
        """
        let page = createPage()
        let pageData = try? JSONEncoder().encode(page)
        let pageJSON = try? JSONSerialization.jsonObject(with: pageData!) as? [String: AnyHashable]
        let internalMessage = InternalMessage(id: "1",
                                              component: "page",
                                              event: "connect",
                                              data: pageJSON!)
        let message = internalMessage.toMessage()
        
        XCTAssertEqual(message.id, "1")
        XCTAssertEqual(message.component, "page")
        XCTAssertEqual(message.event, "connect")
        XCTAssertEqual(message.metadata?.url, "https://37signals.com")
        
        let originalJSONObject = messageJsonData.jsonObject() as? [String: AnyHashable]
        let messageJSONObject = message.jsonData.jsonObject() as? [String: AnyHashable]
        XCTAssertEqual(originalJSONObject, messageJSONObject)
    }
    
    func testToJson() {
        let page = createPage()
        let pageData = try? JSONEncoder().encode(page)
        let pageJSON = try? JSONSerialization.jsonObject(with: pageData!) as? [String: AnyHashable]
        let message = InternalMessage(id: "1",
                                      component: "page",
                                      event: "connect",
                                      data: pageJSON!)
        
        let messageJSONObject = json.jsonObject() as? [String: AnyHashable]
        XCTAssertEqual(message.toJSON(), messageJSONObject)
    }
    
    func testFromJson() {
        let jsonObject = json.jsonObject() as! [String: AnyHashable]
        let message = InternalMessage(jsonObject: jsonObject)
        XCTAssertEqual(message?.id, "1")
        XCTAssertEqual(message?.component, "page")
        XCTAssertEqual(message?.event, "connect")
        
        let page: PageData? = try? message?.data.jsonData()?.decoded()
        XCTAssertEqual(page?.title, "Page-title")
        XCTAssertEqual(page?.subtitle, "Page-subtitle")
        XCTAssertEqual(page?.actions[0], "one")
        XCTAssertEqual(page?.actions[1], "two")
        XCTAssertEqual(page?.actions[2], "three")
    }
    
    func testFromJsonNoData() {
        let noDataJson = """
        {
           "id":"1",
           "component":"page",
           "event":"connect"
        }
        """
        let jsonObject = noDataJson.jsonObject() as! [String: AnyHashable]
        let message = InternalMessage(jsonObject: jsonObject)
        
        XCTAssertEqual(message?.id, "1")
        XCTAssertEqual(message?.data, [:])
    }

    func testFromMessageWithArrayData() {
        let arrayJsonData = """
        ["item1", "item2", "item3"]
        """

        let message = Message(id: "1",
                            component: "page",
                            event: "connect",
                            metadata: .init(url: "https://37signals.com"),
                            jsonData: arrayJsonData)

        let internalMessage = InternalMessage(from: message)

        // Should default to empty dictionary when array data is provided
        XCTAssertEqual(internalMessage.id, "1")
        XCTAssertEqual(internalMessage.component, "page")
        XCTAssertEqual(internalMessage.event, "connect")
        XCTAssertEqual(internalMessage.data, [:])
    }

    func testFromJsonObjectWithArrayData() {
        let jsonObjectWithArray: [String: AnyHashable] = [
            "id": "1",
            "component": "page",
            "event": "connect",
            "data": ["item1", "item2", "item3"]
        ]

        let internalMessage = InternalMessage(jsonObject: jsonObjectWithArray)

        // Should default to empty dictionary when array data is provided
        XCTAssertEqual(internalMessage?.id, "1")
        XCTAssertEqual(internalMessage?.component, "page")
        XCTAssertEqual(internalMessage?.event, "connect")
        XCTAssertEqual(internalMessage?.data, [:])
    }

    func testFromMessageWithValidDictionaryData() {
        let dictionaryJsonData = """
        {"title": "Test Title", "count": 42}
        """
        let message = Message(id: "1",
                            component: "page",
                            event: "connect",
                            metadata: .init(url: "https://37signals.com"),
                            jsonData: dictionaryJsonData)

        let internalMessage = InternalMessage(from: message)

        XCTAssertEqual(internalMessage.id, "1")
        XCTAssertEqual(internalMessage.component, "page")
        XCTAssertEqual(internalMessage.event, "connect")
        XCTAssertEqual(internalMessage.data["title"] as? String, "Test Title")
        XCTAssertEqual(internalMessage.data["count"] as? Int, 42)
    }

    private func createPage() -> PageData {
        return PageData(
            metadata: InternalMessage.Metadata(url: "https://37signals.com"),
            title: "Page-title",
            subtitle: "Page-subtitle",
            actions: ["one", "two", "three"]
        )
    }
}
