@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

@MainActor
final class NewWindowWebViewPolicyDecisionHandlerTests: BaseWebViewPolicyDecisionHandlerTests {
    var policyHandler: NewWindowWebViewPolicyDecisionHandler!

    override func setUp() async throws {
        try await super.setUp()
        policyHandler = NewWindowWebViewPolicyDecisionHandler()
    }

    func test_target_blank_matches() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .targetBlank,
            simulateLinkClickElementId: "externalLink") else {
            XCTFail("No navigation action captured")
            return
        }

        let result = policyHandler.matches(
            navigationAction: action,
            configuration: navigatorConfiguration
        )

        XCTAssertTrue(result)
    }

    func test_handling_matching_result_cancels_web_navigation_and_routes_internally() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .targetBlank,
            simulateLinkClickElementId: "externalLink") else {
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
