import Foundation
import XCTest
@preconcurrency import WebKit

@MainActor
class WebViewPolicyNavigationSimulator: NSObject, WKNavigationDelegate {
    enum SimulateAction {
        case click(String?)
        case submit(String?)

        var elementId: String? {
            switch self {
            case .click(let string), .submit(let string):
                return string
            }
        }
    }

    var capturedNavigationAction: WKNavigationAction?
    var simulateAction: SimulateAction = .click(nil)

    private var didSimulateInteraction: Bool = false
    private var continuation: CheckedContinuation<WKNavigationAction?, Error>?

    let webView: WKWebView

    override init() {
        webView = WKWebView()
        super.init()
        webView.navigationDelegate = self
    }

    /// Loads the given HTML into the web view and awaits the resulting navigation action.
    /// - Parameters:
    ///   - html: The HTML content to load.
    ///   - simulateAction: The interaction to simulate once the page loads: `.click` or
    ///     `.submit` on the element with the given ID. Pass a `nil` element ID to await a
    ///     navigation initiated by the page itself (e.g. via an inline script).
    /// - Returns: The captured `WKNavigationAction`.
    func simulateNavigation(
        withHTML html: String,
        simulateAction: SimulateAction
    ) async throws -> WKNavigationAction? {
        self.simulateAction = simulateAction
        webView.loadHTMLString(html, baseURL: nil)
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let elementId = simulateAction.elementId else { return }
        didSimulateInteraction = true

        let js: String
        switch simulateAction {
        case .click:
            js = "document.getElementById('\(elementId)').click();"
        case .submit:
            js = "document.getElementById('\(elementId)').submit();"
        }

        webView.evaluateJavaScript(js) { [weak self] _, error in
            if let error = error {
                self?.continuation?.resume(throwing: error)
                self?.continuation = nil
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // When awaiting a navigation initiated by the page itself (no simulated interaction),
        // allow the initial about:blank document load produced by `loadHTMLString(_:baseURL:)`
        // so the page can load and run its script, then wait for the page-initiated navigation.
        if simulateAction.elementId == nil,
           navigationAction.navigationType == .other,
           navigationAction.request.url?.absoluteString == "about:blank" {
            decisionHandler(.allow)
            return
        }

        capturedNavigationAction = navigationAction

        // When there is no simulated interaction, or after one is performed, resume the continuation.
        let shouldResumeContinuation = simulateAction.elementId == nil || didSimulateInteraction

        if shouldResumeContinuation {
            // Cancel the actual navigation — we only need the `WKNavigationAction` object.
            // Allowing it would let WKWebView navigate to external URLs (e.g., https://example.com),
            // blocking the shared WKProcessPool and stalling subsequent tests for minutes.
            decisionHandler(.cancel)
            continuation?.resume(returning: navigationAction)
            continuation = nil
        } else {
            // Allow intermediate navigations (e.g., the initial loadHTMLString page load)
            // so the page fully loads and didFinish can trigger the simulated interaction.
            decisionHandler(.allow)
        }
    }

    func stopLoading() {
        webView.stopLoading()
        webView.navigationDelegate = nil
    }
}
