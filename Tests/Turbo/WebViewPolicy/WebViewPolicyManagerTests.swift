@testable import HotwireNative
import XCTest
import WebKit

final class WebViewPolicyManagerTests: XCTestCase {
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )
    let url = URL(string: "https://my.app.com/page")!
    var policyManager: WebViewPolicyManager!
    var webNavigationSimulator: WebViewNavigationSimulator!
    var navigator: Navigator!
    var navigationAction: WKNavigationAction?

    override func setUp() {
        navigator = Navigator(configuration: navigatorConfiguration)

        webNavigationSimulator = WebViewNavigationSimulator()
        webNavigationSimulator.expectation = expectation(description: "Waiting for navigation action triggered by JS click")
    }

    override func tearDown() {
        webNavigationSimulator = nil
    }

    func test_no_handlers_allows_navigation() {
        policyManager = WebViewPolicyManager(policyDecisionHandlers: [])

        let result = policyManager.decidePolicy(
            for: getNavigationAction(),
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertEqual(result, WebViewPolicyManager.Decision.allow)
    }

    func test_no_matching_handlers_allows_navigation() {
        let noMatchSpy1 = NoMatchWebViewPolicyDecisionHandler()
        let noMatchSpy2 = NoMatchWebViewPolicyDecisionHandler()

        policyManager = WebViewPolicyManager(
            policyDecisionHandlers: [
                noMatchSpy1,
                noMatchSpy2
            ]
        )

        let result = policyManager.decidePolicy(
            for: getNavigationAction(),
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertTrue(noMatchSpy1.matchesWasCalled)
        XCTAssertFalse(noMatchSpy1.handleWasCalled)
        XCTAssertTrue(noMatchSpy2.matchesWasCalled)
        XCTAssertFalse(noMatchSpy2.handleWasCalled)
        XCTAssertEqual(result, WebViewPolicyManager.Decision.allow)
    }

    func test_only_first_matching_handler_is_executed() {
        let noMatchSpy = NoMatchWebViewPolicyDecisionHandler()
        let matchSpy1 = MatchWebViewPolicyDecisionHandler()
        let matchSpy2 = MatchWebViewPolicyDecisionHandler()

        policyManager = WebViewPolicyManager(
            policyDecisionHandlers: [
                noMatchSpy,
                matchSpy1,
                matchSpy2
            ]
        )

        let result = policyManager.decidePolicy(
            for: getNavigationAction(),
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertTrue(noMatchSpy.matchesWasCalled)
        XCTAssertFalse(noMatchSpy.handleWasCalled)
        XCTAssertTrue(matchSpy1.matchesWasCalled)
        XCTAssertTrue(matchSpy1.handleWasCalled)
        XCTAssertFalse(matchSpy2.matchesWasCalled)
        XCTAssertFalse(matchSpy2.handleWasCalled)
        XCTAssertEqual(result, WebViewPolicyManager.Decision.cancel)
    }

    func getNavigationAction() -> WKNavigationAction {
        webNavigationSimulator.simulateLinkClickElementId = "link"
        webNavigationSimulator.webView.loadHTMLString(.simpleLink, baseURL: nil)
        waitForExpectations(timeout: 5)
        return webNavigationSimulator.capturedNavigationAction!
    }
}

final class NoMatchWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "no-match-spy"
    var matchesWasCalled = false
    var handleWasCalled = false

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        matchesWasCalled = true
        return false
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        handleWasCalled = true
        return .cancel
    }
}

final class MatchWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "match-spy"
    var matchesWasCalled = false
    var handleWasCalled = false

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        matchesWasCalled = true
        return true
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        handleWasCalled = true
        return .cancel
    }
}
