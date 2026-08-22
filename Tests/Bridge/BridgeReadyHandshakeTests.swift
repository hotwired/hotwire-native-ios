import WebKit
import XCTest
@testable import HotwireNative

/// Drives the real `bridge.js` user script inside a real web view, against a faithful
/// stand-in for `@hotwired/hotwire-native-bridge` 1.1.0, to exercise the web -> native
/// `"ready"` handshake end to end.
@MainActor
final class BridgeReadyHandshakeTests: XCTestCase {
    private var webView: WKWebView!
    private var navigation: NavigationWaiter!
    private var destination: AppBridgeDestination!
    private var delegate: BridgeDelegate!

    override func setUp() async throws {
        webView = WKWebView()
        navigation = NavigationWaiter()
        webView.navigationDelegate = navigation

        Bridge.initialize(webView)

        destination = AppBridgeDestination()
        delegate = BridgeDelegate(location: pageURL.absoluteString,
                                  destination: destination,
                                  componentTypes: [BridgeComponentSpy.self])
    }

    /// The control: a destination owns the web view for the whole load, so `"ready"` lands.
    func testDestinationOwnsTheWebViewWhileTheDocumentLoads() async throws {
        delegate.webViewDidBecomeActive(webView)

        try await loadPage()
        try await waitForRegisteredComponents()

        let supported = try await evaluate("window.nativeBridge.supportedComponents.join(',')") as? String
        XCTAssertEqual(supported, "two")

        let strandedMessages = try await evaluate("window.webBridge.pendingMessages.length") as? Int
        XCTAssertEqual(strandedMessages, 0)

        XCTAssertTrue(destination.onBridgeComponentInitializedWasCalled)
    }

    /// The bug: no destination owns the web view while the document loads, so `"ready"`
    /// is delivered to a nil delegate and discarded. A destination attaching afterwards
    /// — which it must, before a user can see the screen — recovers nothing.
    func testDestinationAttachesAfterTheDocumentLoaded() async throws {
        try await loadPage()

        let supportedBeforeAttach = try await evaluate("window.nativeBridge.supportedComponents.join(',')") as? String
        XCTAssertEqual(supportedBeforeAttach, "")

        delegate.webViewDidBecomeActive(webView)
        try await waitForRegisteredComponents()

        let supported = try await evaluate("window.nativeBridge.supportedComponents.join(',')") as? String
        XCTAssertEqual(supported, "two")

        let strandedMessages = try await evaluate("window.webBridge.pendingMessages.length") as? Int
        XCTAssertEqual(strandedMessages, 0)

        XCTAssertTrue(destination.onBridgeComponentInitializedWasCalled)
    }

    // MARK: Private

    private let pageURL = URL(string: "https://37signals.com/")!

    private func loadPage() async throws {
        webView.loadHTMLString(Self.page, baseURL: pageURL)
        try await navigation.waitForLoad()
    }

    /// The register call is made from a detached `Task`, so the JavaScript lands after the
    /// handshake returns. Poll rather than sleep, and give up rather than hang.
    private func waitForRegisteredComponents() async throws {
        for _ in 0..<50 {
            let count = try await evaluate("window.nativeBridge.supportedComponents.length") as? Int
            if count ?? 0 > 0 { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func evaluate(_ javaScript: String) async throws -> Any? {
        try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(javaScript) { value, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: value)
                }
            }
        }
    }

    /// Mirrors `@hotwired/hotwire-native-bridge` 1.1.0: the web bridge queues component
    /// sends until an adapter is installed, and only `setAdapter` installs one. A bridge
    /// component connects on page load, exactly as a Stimulus `BridgeComponent` does.
    private static let page = """
    <html><head><script>
      class WebBridge {
        constructor() {
          this.adapter = null
          this.pendingMessages = []
          this.lastMessageId = 0
        }
        start() {
          document.dispatchEvent(new Event("web-bridge:ready"))
        }
        supportsComponent(component) {
          return this.adapter ? this.adapter.supportsComponent(component) : false
        }
        send({ component, event, data }) {
          if (!this.adapter) {
            this.pendingMessages.push({ component, event, data })
            return null
          }
          if (!this.supportsComponent(component)) return null
          const id = (++this.lastMessageId).toString()
          this.adapter.receive({ id, component, event, data: data || {} })
          return id
        }
        receive(message) {}
        setAdapter(adapter) {
          this.adapter = adapter
          document.documentElement.dataset.bridgePlatform = adapter.platform
          this.adapterDidUpdateSupportedComponents()
          const pending = this.pendingMessages
          this.pendingMessages = []
          pending.forEach(message => this.send(message))
        }
        adapterDidUpdateSupportedComponents() {
          if (this.adapter) {
            document.documentElement.dataset.bridgeComponents = this.adapter.supportedComponents.join(" ")
          }
        }
      }

      window.webBridge = new WebBridge()
      window.Strada = { web: window.webBridge }
      window.webBridge.start()
      window.webBridge.send({
        component: "two",
        event: "connect",
        data: { metadata: { url: window.location.href } }
      })
    </script></head><body>Hello</body></html>
    """
}

private final class NavigationWaiter: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Error>?
    private var hasLoaded = false

    func waitForLoad() async throws {
        if hasLoaded { return }
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hasLoaded = true
        continuation?.resume()
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
