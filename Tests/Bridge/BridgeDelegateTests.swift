import Foundation
import XCTest
import WebKit
@testable import HotwireNative

class BridgeDelegateTests: XCTestCase {
    private var delegate: BridgeDelegate!
    private var destination: AppBridgeDestination!
    private var bridge: BridgeSpy!
    private let json = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
    """
    
    @MainActor
    override func setUp() async throws {
        destination = AppBridgeDestination()
        delegate = BridgeDelegate(location: "https://37signals.com",
                                  destination: destination,
                                  componentTypes: [OneBridgeComponent.self, BridgeComponentSpy.self])
        
        bridge = BridgeSpy()
        delegate.bridge = bridge
        delegate.onViewDidLoad()
    }
    
    @MainActor
    func testBridgeDidInitialize() async throws {
        await withCheckedContinuation { continuation in
            bridge.registerComponentsContinuation = continuation
            delegate.bridgeDidInitialize()
        }
        
        XCTAssertTrue(bridge.registerComponentsWasCalled)
        XCTAssertEqual(bridge.registerComponentsArg, ["one", "two"])
     
        // Registered components are lazy initialized.
        let componentOne: BridgeComponentSpy? = delegate.component()
        let componentTwo: BridgeComponentSpy? = delegate.component()
        XCTAssertNil(componentOne)
        XCTAssertNil(componentTwo)
    }

    @MainActor
    func testBridgeDidReceiveMessage() {
        let json = """
            {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "two",
                              event: "connect",
                              metadata: .init(url: "https://37signals.com"),
                              jsonData: json)
        
        var component: BridgeComponentSpy? = delegate.component()
        
        XCTAssertNil(component)
        XCTAssertTrue(delegate.bridgeDidReceiveMessage(message))
        
        component = delegate.component()
        
        XCTAssertNotNil(component)
        // Make sure the component has delegate set, and did receive the message.
        XCTAssertTrue(component!.onReceiveMessageWasCalled)
        XCTAssertEqual(component?.onReceiveMessageArg, message)
        XCTAssertNotNil(component?.delegate)
    }
    
    @MainActor
    func testBridgeIgnoresMessageForUnknownComponent() {
        let json = """
            {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: .init(url: "https://37signals.com/another_url"),
                              jsonData: json)
        
        XCTAssertFalse(delegate.bridgeDidReceiveMessage(message))
    }
    
    // Web view URL takes precedence over the provided location.
    @MainActor
    func test_bridgeHandlesRedirectedWebViewURL() {
        let redirectedLocation = "https://37signals.com/sign-in"
        bridge.webView = RedirectedWebView(location: redirectedLocation)
        
        let message = Message(id: "1",
                              component: "two",
                              event: "connect",
                              metadata: .init(url: redirectedLocation),
                              jsonData: json)
        
        var component: BridgeComponentSpy? = delegate.component()
        
        XCTAssertNil(component)
        XCTAssertTrue(delegate.bridgeDidReceiveMessage(message))
        
        component = delegate.component()
        
        XCTAssertNotNil(component)
        // Make sure the component has delegate set, and did receive the message.
        XCTAssertTrue(component!.onReceiveMessageWasCalled)
        XCTAssertEqual(component?.onReceiveMessageArg, message)
        XCTAssertNotNil(component?.delegate)
    }
    
    // When web view URL is nil, the bride delegate falls back to the original location.
    @MainActor
    func test_bridgeFallsbackToOriginalDestination() {
        bridge.webView = RedirectedWebView(location: nil)
        
        let message = Message(id: "1",
                              component: "two",
                              event: "connect",
                              metadata: .init(url: "https://37signals.com"),
                              jsonData: json)
        
        var component: BridgeComponentSpy? = delegate.component()
        
        XCTAssertNil(component)
        XCTAssertTrue(delegate.bridgeDidReceiveMessage(message))
        
        component = delegate.component()
        
        XCTAssertNotNil(component)
        // Make sure the component has delegate set, and did receive the message.
        XCTAssertTrue(component!.onReceiveMessageWasCalled)
        XCTAssertEqual(component?.onReceiveMessageArg, message)
        XCTAssertNotNil(component?.delegate)
    }
    
    @MainActor
    func testBridgeIgnoresMessageForInactiveDestination() {
        let message = Message(id: "1",
                              component: "one",
                              event: "connect",
                              metadata: .init(url: "https://37signals.com"),
                              jsonData: json)
        
        XCTAssertTrue(delegate.bridgeDidReceiveMessage(message))
        
        var component: OneBridgeComponent? = delegate.component()
        XCTAssertNotNil(component)
        
        delegate.onViewDidDisappear()
        XCTAssertFalse(delegate.bridgeDidReceiveMessage(message))
        
        component = delegate.component()
        XCTAssertNil(component)
    }
    
    @MainActor
    func testBridgeForwardsViewWillAppearToComponents() {
        delegate.bridgeDidReceiveMessage(testMessage())
        
        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
        
        delegate.onViewWillAppear()
        XCTAssertTrue(component!.onViewWillAppearWasCalled)
    }
    
    @MainActor
    func testBridgeForwardsViewDidAppearToComponents() {
        delegate.bridgeDidReceiveMessage(testMessage())
        
        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)

        delegate.onViewDidAppear()
        XCTAssertTrue(component!.onViewDidAppearWasCalled)
    }
    
    @MainActor
    func testBridgeForwardsViewWillDisappearToComponents() {
        delegate.bridgeDidReceiveMessage(testMessage())
        
        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
        
        delegate.onViewWillDisappear()
        XCTAssertTrue(component!.onViewWillDisappearWasCalled)
    }
    
    @MainActor
    func testBridgeForwardsViewDidDisappearToComponents() {
        delegate.bridgeDidReceiveMessage(testMessage())
        
        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
        
        delegate.onViewDidDisappear()
        XCTAssertTrue(component!.onViewDidDisappearWasCalled)
    }
    
    @MainActor
    func testBridgeDestinationIsActiveAfterViewWillDisappearIsCalled() {
        delegate.bridgeDidReceiveMessage(testMessage())
        
        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
        
        delegate.onViewWillDisappear()
        XCTAssertTrue(delegate.bridgeDidReceiveMessage(testMessage()))
    }
    
    // MARK: reply(with:)
   
    func test_replyWithSucceedsWhenBridgeIsSet() async throws {
        let message = testMessage()
        let success = try await delegate.reply(with: message)

        XCTAssertTrue(success)
        XCTAssertTrue(bridge.replyWithMessageWasCalled)
        XCTAssertEqual(bridge.replyWithMessageArg, message)
    }
    
    @MainActor
    func test_replyWithFailsWhenBridgeNotSet() async throws {
        delegate.bridge = nil

        let message = testMessage()
        let success = try await delegate.reply(with: message)

        XCTAssertFalse(success)
        XCTAssertFalse(bridge.replyWithMessageWasCalled)
        XCTAssertNil(bridge.replyWithMessageArg)
    }
    
    private func testMessage() -> Message {
        return Message(id: "1",
                       component: "two",
                       event: "connect",
                       metadata: .init(url: "https://37signals.com"),
                       jsonData: json)
    }
}

private final class RedirectedWebView: WKWebView {
    init(location: String?) {
        self.location = location
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var url: URL? {
        guard let location else { return nil }
        
        return URL(string: location)
    }
    
    // MARK: Private
    
    private let location: String?
}
