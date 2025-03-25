@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

final class LinkActivatedWebViewPolicyDecisionHandlerTests: BaseWebViewPolicyDecisionHandlerTests {
    var policyHandler: LinkActivatedWebViewPolicyDecisionHandler!

    override func setUp() {
        super.setUp()
        policyHandler = LinkActivatedWebViewPolicyDecisionHandler()
    }

    func test_link_activated_matches() {
        guard let action = performNavigationTest(withHTML: .simpleLink, elementId: "link") else {
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
    }
}
