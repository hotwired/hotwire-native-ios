@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

final class LinkActivatedWebViewPolicyDecisionHandlerTests: XCTestCase {
    var webView: WKWebView!
    var navigationManager: ClickSimulatorNavigationManager!
    var policyHandler: LinkActivatedWebViewPolicyDecisionHandler!
    var navigatorSpy: NavigationSpy!
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    override func setUp() {
        navigatorSpy = NavigationSpy(configuration: navigatorConfiguration)
        policyHandler = LinkActivatedWebViewPolicyDecisionHandler()
        webView = WKWebView()
        navigationManager = ClickSimulatorNavigationManager()
        navigationManager.expectation = expectation(description: "Waiting for navigation action triggered by JS click")
        webView.navigationDelegate = navigationManager
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
        navigationManager = nil
    }

    func test_link_activated_matches() {
        navigationManager.simulateLinkClickElementId = "link"
        webView.loadHTMLString(.linkActivated, baseURL: nil)

        waitForExpectations(timeout: 10)

        guard let action = navigationManager.capturedNavigationAction else {
            XCTFail("No navigation action captured")
            return
        }

        let result = policyHandler.matches(
            navigationAction: action,
            configuration: navigatorConfiguration
        )

        XCTAssertTrue(result)
    }

    func test_handling_matching_result_cancels_web_navigation() {
        navigationManager.simulateLinkClickElementId = "link"
        webView.loadHTMLString(.linkActivated, baseURL: nil)

        waitForExpectations(timeout: 10)

        guard let action = navigationManager.capturedNavigationAction else {
            XCTFail("No navigation action captured")
            return
        }

        let result = policyHandler.handle(
            navigationAction: action,
            configuration: navigatorConfiguration,
            navigator: navigatorSpy
        )

        XCTAssertEqual(result, WebViewPolicyManager.Decision.cancel)
    }
}

extension String {
    static var linkActivated = """
        <html>
          <body>
            <a id="link" href="https://example.com">Example Link</a>
          </body>
        </html>
        """
}
