import Foundation
import XCTest
@preconcurrency import WebKit

@MainActor
class WebViewNavigationSimulator: NSObject, WKNavigationDelegate {
    var capturedNavigationAction: WKNavigationAction?
    var simulateLinkClickElementId: String?
    
    private var didSimulateLinkClick: Bool = false
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
    ///   - simulateLinkClickElementId: If provided, once the page loads, a simulated click will be triggered on the element with this ID.
    /// - Returns: The captured `WKNavigationAction`.
    func simulateNavigation(withHTML html: String, simulateLinkClickElementId: String? = nil) async throws -> WKNavigationAction? {
        self.simulateLinkClickElementId = simulateLinkClickElementId
        webView.loadHTMLString(html, baseURL: nil)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<WKNavigationAction?, Error>) in
            self.continuation = continuation
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let elementId = simulateLinkClickElementId else { return }
        didSimulateLinkClick = true
        let js = "document.getElementById('\(elementId)').click();"
        webView.evaluateJavaScript(js) { [weak self] (_, error) in
            if let error = error {
                self?.continuation?.resume(throwing: error)
                self?.continuation = nil
            }
        }
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        capturedNavigationAction = navigationAction

        // When there is no simulated click, or after a simulated click is performed, resume the continuation.
        let shouldResumeContinuation = simulateLinkClickElementId == nil || didSimulateLinkClick

        if shouldResumeContinuation {
            // Cancel the actual navigation — we only need the WKNavigationAction object.
            // Allowing it would let WKWebView navigate to external URLs (e.g., https://example.com),
            // blocking the shared WKProcessPool and stalling subsequent tests for minutes.
            decisionHandler(.cancel)
            continuation?.resume(returning: navigationAction)
            continuation = nil
        } else {
            // Allow intermediate navigations (e.g., the initial loadHTMLString page load)
            // so the page fully loads and didFinish can trigger the simulated click.
            decisionHandler(.allow)
        }
    }

    func stopLoading() {
        webView.stopLoading()
        webView.navigationDelegate = nil
    }
}
