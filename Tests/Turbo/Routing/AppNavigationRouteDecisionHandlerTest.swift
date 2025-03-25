@testable import HotwireNative
import WebKit
import XCTest

final class AppNavigationRouteDecisionHandlerTest: XCTestCase {
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )
    var route: AppNavigationRouteDecisionHandler!
    var navigator: Navigator!

    override func setUp() {
        route = AppNavigationRouteDecisionHandler()
        navigator = Navigator(configuration: navigatorConfiguration)
    }

    func test_handling_matching_result_navigates() {
        let url = URL(string: "https://my.app.com/page")!
        let result = route.handle(location: url, configuration: navigatorConfiguration, navigator: navigator)
        XCTAssertEqual(result, Router.Decision.navigate)
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
}
