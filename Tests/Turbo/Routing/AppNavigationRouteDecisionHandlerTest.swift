@testable import HotwireNative
import WebKit
import XCTest

final class AppNavigationRouteDecisionHandlerTest: XCTestCase {
    var route = AppNavigationRouteDecisionHandler()
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    func test_matching_result_navigates() {
        XCTAssertEqual(route.decision, Router.Decision.navigate)
    }

    func test_url_on_app_domain_matches() {
        let url = URL(string: "https://my.app.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertTrue(result)
    }

    func test_url_without_subdomain_does_not_match() {
        let url = URL(string: "https://app.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertFalse(result)
    }

    func test_masqueraded_url_does_not_match() {
        let url = URL(string: "https://app.my.com@fake.domain")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertFalse(result)
    }

    func test_matching_navigation_action_policy_cancels_web_navigation() {
        XCTAssertEqual(route.navigationActionPolicy, WKNavigationActionPolicy.cancel)
    }
}
