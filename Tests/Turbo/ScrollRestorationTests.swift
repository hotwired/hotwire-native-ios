import WebKit
import XCTest

@testable import HotwireNative

class ScrollRestorationTests: XCTestCase {
    private var session: Session!
    private var webView: WKWebView!

    @MainActor
    override func setUp() async throws {
        session = Session()
        webView = session.webView
    }

    override func tearDown() {
        session = nil
        webView = nil
    }

    @MainActor
    func test_deactivateWebView_preservesScrollPosition() async throws {
        let visitable1 = VisitableViewController(url: URL(string: "http://example.com/page1")!)
        let visitable2 = VisitableViewController(url: URL(string: "http://example.com/page2")!)

        activate(visitable1)
        webView.scrollView.contentOffset = CGPoint(x: 0, y: 500)

        deactivate(visitable1)
        activate(visitable2)

        visitable1.appearReason = .revealedByPop
        deactivate(visitable2)
        activate(visitable1)

        XCTAssertEqual(webView.scrollView.contentOffset.y, 500, accuracy: 1.0)
    }

    @MainActor
    func test_activateWebView_startsAtTop() async throws {
        let visitable1 = VisitableViewController(url: URL(string: "http://example.com/page1")!)
        let visitable2 = VisitableViewController(url: URL(string: "http://example.com/page2")!)

        activate(visitable1)
        webView.scrollView.contentOffset = CGPoint(x: 0, y: 300)
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)

        deactivate(visitable1)
        activate(visitable2)

        XCTAssertEqual(webView.scrollView.contentOffset.y, 0, accuracy: 1.0)
    }

    @MainActor
    func test_scrollRestoration_unaffectedByKeyboardOnSubsequentPage() async throws {
        let visitable1 = VisitableViewController(url: URL(string: "http://example.com/page1")!)
        let visitable2 = VisitableViewController(url: URL(string: "http://example.com/page2")!)

        activate(visitable1)
        webView.scrollView.contentOffset = CGPoint(x: 0, y: 500)

        deactivate(visitable1)
        activate(visitable2)

        // Simulate keyboard appearance on page 2
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)
        webView.scrollView.contentOffset = CGPoint(x: 0, y: 100)

        visitable1.appearReason = .revealedByPop
        deactivate(visitable2)
        activate(visitable1)

        XCTAssertEqual(webView.scrollView.contentOffset.y, 500, accuracy: 10.0)
    }

    // MARK: - Helpers

    @MainActor
    private func activate(_ visitable: VisitableViewController) {
        visitable.visitableDelegate = session
        session.activateVisitable(visitable)
    }

    @MainActor
    private func deactivate(_ visitable: VisitableViewController) {
        session.deactivateActivatedVisitable()
    }
}
