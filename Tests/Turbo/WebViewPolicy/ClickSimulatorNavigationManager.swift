import Foundation
import XCTest
@preconcurrency import WebKit

class ClickSimulatorNavigationManager: NSObject, WKNavigationDelegate {
    var expectation: XCTestExpectation?
    var capturedNavigationAction: WKNavigationAction?
    var simulateLinkClickElementId: String?

    private var didSimulateLinkClick: Bool = false

    // MARK: WKNavigationDelegate

    // Once the page loads, execute JavaScript to simulate a user click on the link.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let simulateLinkClickElementId else { return }
        didSimulateLinkClick = true
        let js = "document.getElementById('\(simulateLinkClickElementId)').click();"
        webView.evaluateJavaScript(js) { (_, error) in
            if let error = error {
                XCTFail("Error evaluating JS: \(error)")
            }
        }
    }

    // Capture the navigation action when it is triggered.
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        capturedNavigationAction = navigationAction
        decisionHandler(.allow)

        if simulateLinkClickElementId == nil {
            expectation?.fulfill()
        }

        if didSimulateLinkClick {
            expectation?.fulfill()
        }
    }
}
