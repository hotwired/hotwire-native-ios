@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

@MainActor
class BaseWebViewPolicyDecisionHandlerTests: XCTestCase {
    var webNavigationSimulator: WebViewNavigationSimulator!
    var navigatorSpy: NavigationSpy!
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    override func setUp() async throws {
        navigatorSpy = NavigationSpy(configuration: navigatorConfiguration)
        webNavigationSimulator = WebViewNavigationSimulator()
    }

    override func tearDown() async throws {
        webNavigationSimulator = nil
    }
}
