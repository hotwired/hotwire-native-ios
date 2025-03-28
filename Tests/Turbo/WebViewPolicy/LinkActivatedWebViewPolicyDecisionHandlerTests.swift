@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

@MainActor
final class LinkActivatedWebViewPolicyDecisionHandlerTests: BaseWebViewPolicyDecisionHandlerTests {
    var policyHandler: LinkActivatedWebViewPolicyDecisionHandler!
    
    override func setUp() async throws {
        try await super.setUp()
        policyHandler = LinkActivatedWebViewPolicyDecisionHandler()
    }
    
    func test_link_activated_matches() async throws {
        guard let action = try await webNavigationSimulator.simulateNavigation(
            withHTML: .simpleLink,
            simulateLinkClickElementId: "link") else {
            XCTFail("No navigation action captured")
            return
        }
        
        let result = policyHandler.matches(
            navigationAction: action,
            configuration: navigatorConfiguration
        )
        
        XCTAssertTrue(result)
    }
    
    func test_handling_matching_result_cancels_web_navigation() async throws {
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
    }
}
