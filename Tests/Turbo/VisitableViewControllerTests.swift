@testable import HotwireNative
import WebKit
import XCTest

class VisitableViewControllerTests: XCTestCase {
    var viewController: VisitableViewController!
    var webView: WebViewSpy!
    let originalURL = URL(string: "https://example.com")!

    override func setUp() {
        webView = WebViewSpy(frame: .zero)
        webView.overriddenURL = originalURL
        viewController = VisitableViewController(url: originalURL)
    }

    func test_visitableURL_and_currentURL_match_on_init() {
        XCTAssertEqual(viewController.initialVisitableURL, originalURL)
        XCTAssertEqual(viewController.currentVisitableURL, originalURL)
    }

    func test_currentURL_matches_new_webview_url_on_webView_activated_and_rendered() {
        viewController.visitableView.activateWebView(webView, forVisitable: viewController)
        viewController.visitableDidRender()

        XCTAssertEqual(viewController.initialVisitableURL, originalURL)
        XCTAssertEqual(viewController.currentVisitableURL, originalURL)

        let overriddenURL = URL(string: "https://example.com?tab=a")!
        webView.overriddenURL = overriddenURL

        XCTAssertEqual(viewController.initialVisitableURL, originalURL)
        XCTAssertEqual(viewController.currentVisitableURL, overriddenURL)
    }

    func test_currentURL_matches_new_webview_url_on_webView_deactivation() {
        viewController.visitableView.activateWebView(webView, forVisitable: viewController)
        viewController.visitableDidRender()

        XCTAssertEqual(viewController.initialVisitableURL, originalURL)
        XCTAssertEqual(viewController.currentVisitableURL, originalURL)

        let overriddenURL = URL(string: "https://example.com?tab=a")!
        webView.overriddenURL = overriddenURL
        viewController.visitableWillDeactivateWebView()
        viewController.visitableDidDeactivateWebView()

        XCTAssertEqual(viewController.initialVisitableURL, originalURL)
        XCTAssertEqual(viewController.currentVisitableURL, overriddenURL)
    }
}

final class WebViewSpy: WKWebView {
    var overriddenURL: URL?

    override var url: URL? {
        overriddenURL
    }
}
