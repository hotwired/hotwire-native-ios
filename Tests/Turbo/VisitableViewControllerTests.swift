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

    func test_webview_is_first_child_during_loading() {
        XCTAssertEqual(viewController.visitableView.subviews.first, viewController.visitableView.activityIndicatorView)

        viewController.visitableView.activateWebView(webView, forVisitable: viewController)

        XCTAssertEqual(viewController.visitableView.subviews.first, webView)
        XCTAssertEqual(viewController.visitableView.subviews.last, viewController.visitableView.activityIndicatorView)
    }

    func test_webview_is_first_child_on_restore() {
        XCTAssertEqual(viewController.visitableView.subviews.first, viewController.visitableView.activityIndicatorView)

        viewController.showVisitableScreenshot()
        viewController.visitableView.activateWebView(webView, forVisitable: viewController)

        XCTAssertEqual(viewController.visitableView.subviews.count, 3)
        XCTAssertEqual(viewController.visitableView.subviews.first, viewController.visitableView.webView)

        viewController.hideVisitableScreenshot()

        XCTAssertEqual(viewController.visitableView.subviews.count, 2)
        XCTAssertEqual(viewController.visitableView.subviews.first, viewController.visitableView.webView)
    }

    @available(iOS 15.0, *)
    func test_activating_webview_designates_its_scroll_view_as_content_scroll_view() {
        XCTAssertNil(viewController.contentScrollView(for: .top))

        viewController.activateVisitableWebView(webView)

        XCTAssertEqual(viewController.contentScrollView(for: .top), webView.scrollView)
        XCTAssertEqual(viewController.contentScrollView(for: .bottom), webView.scrollView)
    }

    @available(iOS 15.0, *)
    func test_deactivating_webview_clears_the_content_scroll_view() {
        viewController.activateVisitableWebView(webView)
        XCTAssertEqual(viewController.contentScrollView(for: .top), webView.scrollView)

        viewController.deactivateVisitableWebView()

        XCTAssertNil(viewController.contentScrollView(for: .top))
    }

    #if compiler(>=6.2)
    @available(iOS 26.0, *)
    func test_activating_webview_applies_the_configured_top_edge_effect_style() {
        Hotwire.config.webViewTopEdgeEffectStyle = .soft
        defer { Hotwire.config.webViewTopEdgeEffectStyle = nil }
        webView.scrollView.topEdgeEffect.style = .hard

        viewController.activateVisitableWebView(webView)

        XCTAssertEqual(webView.scrollView.topEdgeEffect.style, .soft)
    }

    @available(iOS 26.0, *)
    func test_activating_webview_keeps_the_top_edge_effect_style_when_not_configured() {
        webView.scrollView.topEdgeEffect.style = .hard

        viewController.activateVisitableWebView(webView)

        XCTAssertEqual(webView.scrollView.topEdgeEffect.style, .hard)
    }
    #endif
}

final class WebViewSpy: WKWebView {
    var overriddenURL: URL?

    override var url: URL? {
        overriddenURL
    }
}
