@testable import HotwireNative
@preconcurrency import WebKit
import XCTest

final class NewWindowWebViewPolicyDecisionHandlerTests: XCTestCase {
    var webView: WKWebView!
    var navigationManager: ClickSimulatorNavigationManager!
    var policyHandler: NewWindowWebViewPolicyDecisionHandler!
    var navigatorSpy: NavigationSpy!
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )

    override func setUp() {
        navigatorSpy = NavigationSpy(configuration: navigatorConfiguration)
        policyHandler = NewWindowWebViewPolicyDecisionHandler()
        webView = WKWebView()
        navigationManager = ClickSimulatorNavigationManager()
        navigationManager.expectation = expectation(description: "Waiting for navigation action triggered by JS click")
        webView.navigationDelegate = navigationManager
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
        navigationManager = nil
    }

    func test_target_blank_matches() {
        navigationManager.simulateLinkClickElementId = "externalLink"
        webView.loadHTMLString(.targetBlank, baseURL: nil)

        waitForExpectations(timeout: 10)

        guard let action = navigationManager.capturedNavigationAction else {
            XCTFail("No navigation action captured")
            return
        }

        let result = policyHandler.matches(
            navigationAction: action,
            configuration: navigatorConfiguration
        )

        XCTAssertTrue(result)
    }

    func test_handling_matching_result_cancels_web_navigation_and_routes_internally() {
        navigationManager.simulateLinkClickElementId = "externalLink"
        webView.loadHTMLString(.targetBlank, baseURL: nil)

        waitForExpectations(timeout: 10)

        guard let action = navigationManager.capturedNavigationAction else {
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

extension String {
    static var targetBlank = """
        <html>
          <body>
            <a id="externalLink" href="https://example.com" target="_blank">External Link</a>
          </body>
        </html>
        """
}

final class NavigationSpy: Navigator {
    var routeWasCalled = false
    var routeURL: URL?

    init(configuration: Navigator.Configuration) {
        super.init(
            session: Session(webView: Hotwire.config.makeWebView()),
            modalSession: Session(webView: Hotwire.config.makeWebView()),
            configuration: configuration
        )
    }

    override func route(_ url: URL, options: VisitOptions? = VisitOptions(action: .advance), parameters: [String : Any]? = nil) {
        routeWasCalled = true
        routeURL = url
    }
}
