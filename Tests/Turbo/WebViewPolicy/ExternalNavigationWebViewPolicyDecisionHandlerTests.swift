@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

@MainActor
final class ExternalNavigationWebViewPolicyDecisionHandlerTests: BaseWebViewPolicyDecisionHandlerTests {
    var policyHandler: ExternalNavigationWebViewPolicyDecisionHandler!

    override func setUp() async throws {
        try await super.setUp()
        policyHandler = ExternalNavigationWebViewPolicyDecisionHandler()
    }

    func test_link_activated_matches() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .simpleLink,
            simulateLinkClickElementId: "link") else {
                XCTFail("No navigation action captured")
                return
            }
        let result = policyHandler.matches(navigationAction: action, configuration: navigatorConfiguration)
        XCTAssertTrue(result)
    }

    func test_handling_link_activated_cancels_web_navigation_and_routes_internally() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .simpleLink,
            simulateLinkClickElementId: "link") else {
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

    func test_js_click_matches() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .jsClick,
            simulateLinkClickElementId: nil) else {
            XCTFail("No navigation action captured")
            return
        }
        let result = policyHandler.matches(navigationAction: action, configuration: navigatorConfiguration)
        XCTAssertTrue(result)
    }

    func test_handling_js_click_cancels_web_navigation_and_routes_internally() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .jsClick,
            simulateLinkClickElementId: nil) else {
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
