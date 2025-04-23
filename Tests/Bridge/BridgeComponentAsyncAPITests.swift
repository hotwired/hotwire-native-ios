import Foundation
import HotwireNative
import WebKit
import XCTest

@MainActor
class BridgeComponentAsyncAPITests: XCTestCase {
    private var delegate: BridgeDelegateSpy!
    private var destination: AppBridgeDestination!
    private var component: OneBridgeComponent!
    private let message = Message(id: "1",
                                  component: OneBridgeComponent.name,
                                  event: "connect",
                                  metadata: .init(url: "https://37signals.com"),
                                  jsonData: "{\"title\":\"Page-title\",\"subtitle\":\"Page-subtitle\"}")

    override func setUp() async throws {
        destination = AppBridgeDestination()
        delegate = BridgeDelegateSpy()
        component = OneBridgeComponent(destination: destination, delegate: delegate)
        component.didReceive(message: message)
    }

    func test_didReceiveCachesTheMessage() {
        let cachedMessage = component.receivedMessage(for: "connect")
        XCTAssertEqual(cachedMessage, message)
    }

    func test_replyWithNilDelegateReturnsFalse() async throws {
        component.delegate = nil
        let success = try await component.reply(to: "connect")

        XCTAssertFalse(success)
    }

    func test_replyToReceivedMessageSucceeds() async throws {
        let success = try await component.reply(to: "connect")

        XCTAssertTrue(success)
        XCTAssertTrue(delegate.replyWithMessageWasCalled)
        XCTAssertEqual(delegate.replyWithMessageArg, message)
    }

    func test_replyToReceivedMessageWithACodableObjectSucceeds() async throws {
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        let newJsonData = "{\"title\":\"hey\",\"subtitle\":\"\",\"actionName\":\"tap\"}"
        let newMessage = message.replacing(jsonData: newJsonData)

        let success = try await component.reply(to: "connect", with: messageData)

        XCTAssertTrue(success)
        XCTAssertTrue(delegate.replyWithMessageWasCalled)
        XCTAssertEqual(delegate.replyWithMessageArg, newMessage)
    }

    func test_replyToMessageNotReceivedWithACodableObjectIgnoresTheReply() async throws {
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")

        let success = try await component.reply(to: "disconnect", with: messageData)

        XCTAssertFalse(success)
        XCTAssertFalse(delegate.replyWithMessageWasCalled)
        XCTAssertNil(delegate.replyWithMessageArg)
    }

    func test_replyToMessageNotReceivedIgnoresTheReply() async throws {
        let success = try await component.reply(to: "disconnect")

        XCTAssertFalse(success)
        XCTAssertFalse(delegate.replyWithMessageWasCalled)
        XCTAssertNil(delegate.replyWithMessageArg)
    }

    func test_replyToMessageNotReceivedWithJsonDataIgnoresTheReply() async throws {
        let success = try await component.reply(to: "disconnect", with: "{\"title\":\"Page-title\"}")

        XCTAssertFalse(success)
        XCTAssertFalse(delegate.replyWithMessageWasCalled)
        XCTAssertNil(delegate.replyWithMessageArg)
    }

    func test_replyWithSucceedsWhenBridgeIsSet() async throws {
        let newJsonData = "{\"title\":\"Page-title\"}"
        let newMessage = message.replacing(jsonData: newJsonData)

        let success = try await component.reply(with: newMessage)

        XCTAssertTrue(success)
        XCTAssertTrue(delegate.replyWithMessageWasCalled)
        XCTAssertEqual(delegate.replyWithMessageArg, newMessage)
    }
}
