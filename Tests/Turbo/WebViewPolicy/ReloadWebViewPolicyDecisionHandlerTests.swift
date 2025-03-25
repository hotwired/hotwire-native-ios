@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

final class ReloadWebViewPolicyDecisionHandlerTests: XCTestCase {
    var webView: WKWebView!
    var navigationManager: ClickSimulatorNavigationManager!
    var policyHandler: ReloadWebViewPolicyDecisionHandler!
    var navigatorSpy: NavigationSpy!
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    override func setUp() {
        navigatorSpy = NavigationSpy(configuration: navigatorConfiguration)
        policyHandler = ReloadWebViewPolicyDecisionHandler()
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

    func test_reload_matches() {
        navigationManager.simulateLinkClickElementId = "reloadButton"
        webView.loadHTMLString(.reload, baseURL: nil)

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

    func test_handling_matching_result_cancels_web_navigation_and_reloads() {
        navigationManager.simulateLinkClickElementId = "reloadButton"
        webView.loadHTMLString(.reload, baseURL: nil)

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
        XCTAssertTrue(navigatorSpy.reloadWasCalled)
    }
}

extension String {
    static var reload = """
        <html>
            <body>
            <p>Click the button below to reload the page.</p>
                <button id="reloadButton" onclick="location.reload();">Reload Page</button>
            </body>
        </html>
        """
}
