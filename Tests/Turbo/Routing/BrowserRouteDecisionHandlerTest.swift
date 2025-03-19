@testable import HotwireNative
import WebKit
import XCTest

final class BrowserRouteDecisionHandlerTest: XCTestCase {
    var route = BrowserRouteDecisionHandler()
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    func test_matching_result_stops_navigation() {
        XCTAssertEqual(route.decision, Router.Decision.cancel)
    }

    func test_url_on_external_domain_matches() {
        let url = URL(string: "https://external.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertTrue(result)
    }

    func test_url_without_subdomain_matches() {
        let url = URL(string: "https://app.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertTrue(result)
    }

    func test_url_on_app_domain_does_not_match() {
        let url = URL(string: "https://my.app.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertFalse(result)
    }

    func test_matching_navigation_action_policy_cancels_web_navigation() {
        XCTAssertEqual(route.navigationActionPolicy, WKNavigationActionPolicy.cancel)
    }
}
