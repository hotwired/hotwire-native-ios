import Foundation
import HotwireNative
import WebKit
import XCTest

@MainActor
class BridgeComponentTest: XCTestCase {
    private var delegate: BridgeDelegateSpy!
    private var destination: AppBridgeDestination!
    private var component: OneBridgeComponent!
    private let message = Message(id: "1",
                                  component: OneBridgeComponent.name,
                                  event: "connect",
                                  metadata: .init(url: "https://37signals.com"),
                                  jsonData: "{\"title\":\"Page-title\",\"subtitle\":\"Page-subtitle\"}")

    override func setUp() {
        destination = AppBridgeDestination()
        delegate = BridgeDelegateSpy()
        component = OneBridgeComponent(destination: destination, delegate: delegate)
        component.didReceive(message: message)
    }

    func test_didReceiveCachesTheMessage() {
        let cachedMessage = component.receivedMessage(for: "connect")
        XCTAssertEqual(cachedMessage, message)
    }

    func test_didReceiveCachesOnlyTheLastMessage() {
        let newJsonData = "{\"title\":\"Page-title\"}"
        let newMessage = message.replacing(jsonData: newJsonData)

        component.didReceive(message: newMessage)

        let cachedMessage = component.receivedMessage(for: "connect")
        XCTAssertEqual(cachedMessage, newMessage)
    }

    func test_retrievingNonCachedMessageForEvent() {
        let cachedMessage = component.receivedMessage(for: "disconnect")
        XCTAssertNil(cachedMessage)
    }

    func test_replyWithNilDelegateReturnsFalse() {
        let expectation = expectation(description: "Wait for completion.")
        component.delegate = nil

        component.reply(to: "connect") { result in
            switch result {
            case .success(let success):
                XCTAssertFalse(success)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }

    func test_replyToReceivedMessageSucceeds() {
        let expectation = expectation(description: "Wait for completion.")

        component.reply(to: "connect") { [unowned self] result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertTrue(delegate.replyWithMessageWasCalled)
                XCTAssertEqual(delegate.replyWithMessageArg, message)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }

    func test_replyToReceivedMessageWithACodableObjectSucceeds() {
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        let newJsonData = "{\"title\":\"hey\",\"subtitle\":\"\",\"actionName\":\"tap\"}"
        let newMessage = message.replacing(jsonData: newJsonData)
        let expectation = expectation(description: "Wait for completion.")

        component.reply(to: "connect", with: messageData) { [unowned self] result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertTrue(delegate.replyWithMessageWasCalled)
                XCTAssertEqual(delegate.replyWithMessageArg, newMessage)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }

    func test_replyToMessageNotReceivedWithACodableObjectIgnoresTheReply() {
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        let expectation = expectation(description: "Wait for completion.")

        component.reply(to: "disconnect", with: messageData) { [unowned self] result in
            switch result {
            case .success(let success):
                XCTAssertFalse(success)
                XCTAssertFalse(delegate.replyWithMessageWasCalled)
                XCTAssertNil(delegate.replyWithMessageArg)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }

    func test_replyToMessageNotReceivedIgnoresTheReply() {
        let expectation = expectation(description: "Wait for completion.")

        component.reply(to: "disconnect") { [unowned self] result in
            switch result {
            case .success(let success):
                XCTAssertFalse(success)
                XCTAssertFalse(delegate.replyWithMessageWasCalled)
                XCTAssertNil(delegate.replyWithMessageArg)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }

    func test_replyToMessageNotReceivedWithJsonDataIgnoresTheReply() {
        let expectation = expectation(description: "Wait for completion.")

        component.reply(to: "disconnect", with: "{\"title\":\"Page-title\"}") { [unowned self] result in
            switch result {
            case .success(let success):
                XCTAssertFalse(success)
                XCTAssertFalse(delegate.replyWithMessageWasCalled)
                XCTAssertNil(delegate.replyWithMessageArg)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }

    func test_replyWithSucceedsWhenBridgeIsSet() {
        let expectation = expectation(description: "Wait for completion.")

        let newJsonData = "{\"title\":\"Page-title\"}"
        let newMessage = message.replacing(jsonData: newJsonData)

        component.reply(with: newMessage) { [unowned self] result in
            switch result {
            case .success(let success):
                XCTAssert(success)
                XCTAssertTrue(delegate.replyWithMessageWasCalled)
                XCTAssertEqual(delegate.replyWithMessageArg, newMessage)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }
}
