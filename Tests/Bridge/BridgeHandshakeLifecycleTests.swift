import Embassy
@testable import HotwireNative
import WebKit
import XCTest

/// Drives a real `Session` against a real server, through the UIKit lifecycle a destination
/// receives when something is presented over it while its page is still loading.
@MainActor
final class BridgeHandshakeLifecycleTests: XCTestCase {
    private var eventLoop: SelectorEventLoop!
    private var server: DefaultHTTPServer!
    private var session: Session!
    private var destination: TestBridgeDestination!

    override func setUp() async throws {
        Hotwire.registerBridgeComponents([BridgeComponentSpy.self])

        session = Session(webView: Hotwire.config.makeWebView())
        destination = TestBridgeDestination(url: pageURL)

        eventLoop = try SelectorEventLoop(selector: KqueueSelector())
        server = DefaultHTTPServer.turboServer(eventLoop: eventLoop)
        try server.start()
        DispatchQueue.global().async { self.eventLoop.runForever() }
    }

    override func tearDown() {
        server.stopAndWait()
        eventLoop.stop()
        Hotwire.registerBridgeComponents([])
    }

    /// The control: nothing covers the destination, so it owns the web view for the whole load.
    func testDestinationStaysOnScreenWhileItsPageLoads() async throws {
        _ = destination.view

        session.visit(destination)
        try await waitForPageScript()
        destination.viewDidAppear(false)

        try await waitForRegisteredComponents()

        let supported = try await evaluate("window.nativeBridge.supportedComponents.join(',')") as? String
        XCTAssertEqual(supported, "two")

        let strandedMessages = try await evaluate("window.webBridge.pendingMessages.length") as? Int
        XCTAssertEqual(strandedMessages, 0)

        XCTAssertNotNil(connectedComponent)
    }

    /// The bug: something is presented over the destination while its page is still loading,
    /// so UIKit sends `viewDidDisappear` and the session hands the web view back. The document
    /// then announces itself to a bridge with no delegate. Returning to the screen re-attaches
    /// the destination and re-shows the rendered page, but recovers no bridge.
    func testDestinationIsCoveredWhileItsPageLoads() async throws {
        _ = destination.view

        session.visit(destination)
        destination.viewDidDisappear(false)

        XCTAssertTrue(destination.visitableDidDeactivateWebViewWasCalled)

        try await waitForPageScript()

        destination.viewDidAppear(false)
        try await waitForRegisteredComponents()

        let supported = try await evaluate("window.nativeBridge.supportedComponents.join(',')") as? String
        XCTAssertEqual(supported, "two")

        let strandedMessages = try await evaluate("window.webBridge.pendingMessages.length") as? Int
        XCTAssertEqual(strandedMessages, 0)

        XCTAssertNotNil(connectedComponent)
    }

    // MARK: Private

    /// Non-nil once a component message has actually reached native for this destination.
    private var connectedComponent: BridgeComponentSpy? {
        destination.bridgeDelegate.component()
    }

    private let pageURL = URL(string: "http://localhost:8080/bridge-components")!

    private func waitForPageScript() async throws {
        try await poll { try await self.evaluate("typeof window.webBridge") as? String == "object" }
    }

    /// The register call is made from a detached `Task`, so the JavaScript lands after the
    /// handshake returns. Poll rather than sleep, and give up rather than hang.
    private func waitForRegisteredComponents() async throws {
        try await poll { try await self.evaluate("window.nativeBridge.supportedComponents.length") as? Int ?? 0 > 0 }
    }

    private func poll(until condition: () async throws -> Bool) async throws {
        for _ in 0..<100 {
            if (try? await condition()) == true { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func evaluate(_ javaScript: String) async throws -> Any? {
        try await withCheckedThrowingContinuation { continuation in
            session.webView.evaluateJavaScript(javaScript) { value, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: value)
                }
            }
        }
    }
}

private final class TestBridgeDestination: HotwireWebViewController {
    private(set) var visitableDidDeactivateWebViewWasCalled = false

    override func visitableDidDeactivateWebView() {
        visitableDidDeactivateWebViewWasCalled = true
        super.visitableDidDeactivateWebView()
    }
}
