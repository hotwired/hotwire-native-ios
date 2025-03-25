@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

final class ReloadWebViewPolicyDecisionHandlerTests: BaseWebViewPolicyDecisionHandlerTests {
    var policyHandler: ReloadWebViewPolicyDecisionHandler!

    override func setUp() {
        super.setUp()
        policyHandler = ReloadWebViewPolicyDecisionHandler()
    }

    func test_reload_matches() {
        guard let action = performNavigationTest(withHTML: .reload, elementId: "reloadButton") else {
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
        guard let action = performNavigationTest(withHTML: .reload, elementId: "reloadButton") else {
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
