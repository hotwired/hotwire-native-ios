@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

class BaseWebViewPolicyDecisionHandlerTests: XCTestCase {
    var webNavigationSimulator: WebViewNavigationSimulator!
    var navigatorSpy: NavigationSpy!
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    override func setUp() {
        navigatorSpy = NavigationSpy(configuration: navigatorConfiguration)
        webNavigationSimulator = WebViewNavigationSimulator()
        webNavigationSimulator.expectation = expectation(description: "Waiting for navigation action triggered by JS click")
    }

    override func tearDown() {
        webNavigationSimulator = nil
    }

    /// Helper to load a given HTML string and wait for a navigation action.
    /// - Parameter html: The HTML content to load.
    /// - Parameter elementId: The id of the element that will be "clicked" via JavaScript.
    /// - Returns: The captured navigation action, if any.
    func performNavigationTest(withHTML html: String, elementId: String?) -> WKNavigationAction? {
        webNavigationSimulator.simulateLinkClickElementId = elementId
        webNavigationSimulator.webView.loadHTMLString(html, baseURL: nil)
        waitForExpectations(timeout: 5)
        return webNavigationSimulator.capturedNavigationAction
    }
}

final class ExternalNavigationWebViewPolicyDecisionHandlerTests: BaseWebViewPolicyDecisionHandlerTests {
    var policyHandler: ExternalNavigationWebViewPolicyDecisionHandler!

    override func setUp() {
        super.setUp()
        policyHandler = ExternalNavigationWebViewPolicyDecisionHandler()
    }

    func test_link_activated_matches() {
        guard let action = performNavigationTest(withHTML: .simpleLink, elementId: "link") else {
            XCTFail("No navigation action captured")
            return
        }
        let result = policyHandler.matches(navigationAction: action, configuration: navigatorConfiguration)
        XCTAssertTrue(result)
    }

    func test_handling_link_activated_cancels_web_navigation_and_routes_internally() {
        guard let action = performNavigationTest(withHTML: .simpleLink, elementId: "link") else {
            XCTFail("No navigation action captured")
            return
        }
        let result = policyHandler.handle(
            navigationAction: action,
            configuration: navigatorConfiguration,
            navigator: navigatorSpy
        )
        XCTAssertEqual(result, WebViewPolicyManager.Decision.cancel)
        XCTAssertTrue(navigatorSpy.routeWasCalled)
        XCTAssertEqual(action.request.url, navigatorSpy.routeURL)
    }

    func test_js_click_matches() {
        guard let action = performNavigationTest(withHTML: .jsClick, elementId: nil) else {
            XCTFail("No navigation action captured")
            return
        }
        let result = policyHandler.matches(navigationAction: action, configuration: navigatorConfiguration)
        XCTAssertTrue(result)
    }

    func test_handling_js_click_cancels_web_navigation_and_routes_internally() {
        guard let action = performNavigationTest(withHTML: .jsClick, elementId: nil) else {
            XCTFail("No navigation action captured")
            return
        }
        let result = policyHandler.handle(
            navigationAction: action,
            configuration: navigatorConfiguration,
            navigator: navigatorSpy
        )
        XCTAssertEqual(result, WebViewPolicyManager.Decision.cancel)
        XCTAssertTrue(navigatorSpy.routeWasCalled)
        XCTAssertEqual(action.request.url, navigatorSpy.routeURL)
    }
}
