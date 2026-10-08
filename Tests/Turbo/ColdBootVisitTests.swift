import Embassy
@testable import HotwireNative
import WebKit
import XCTest

class ColdBootVisitTests: XCTestCase {
    private let webView = WKWebView()
    private let visitDelegate = TestVisitDelegate()
    private var visit: ColdBootVisit!
    private var visitable: TestVisitable!
    let url = URL(string: "http://localhost/")!

    override func setUp() {

        let bridge = WebViewBridge(webView: webView)
        visitable = TestVisitable(url: url)
        visitable.currentVisitableURL = URL(string: "http://localhost/new")!

        visit = ColdBootVisit(visitable: visitable, options: VisitOptions(), bridge: bridge)
        visit.delegate = visitDelegate
    }

    func test_start_transitionsToStartState() {
        XCTAssertEqual(visit.state, .initialized)
        visit.start()
        XCTAssertEqual(visit.state, .started)
    }

    func test_start_notifiesTheDelegateTheVisitWillStart() {
        visit.start()
        XCTAssertTrue(visitDelegate.didCall("visitWillStart(_:)"))
    }

    func test_start_kicksOffTheWebViewLoad() {
        visit.start()
        XCTAssertNotNil(visit.navigation)
    }

    func test_visit_becomesTheNavigationDelegate() {
        visit.start()
        XCTAssertIdentical(webView.navigationDelegate, visit)
    }

    func test_visit_notifiesTheDelegateTheVisitDidStart() {
        visit.start()
        XCTAssertTrue(visitDelegate.didCall("visitDidStart(_:)"))
    }

    func test_visit_ignoresTheCallIfAlreadyStarted() {
        visit.start()
        XCTAssertTrue(visitDelegate.methodsCalled.contains("visitDidStart(_:)"))

        visitDelegate.methodsCalled.remove("visitDidStart(_:)")
        visit.start()
        XCTAssertFalse(visitDelegate.didCall("visitDidStart(_:)"))
    }

    func test_visit_takesTheCurrentVisitableURL() {
        visit.start()
        XCTAssertTrue(visitDelegate.visitDidStartWasCalled)
        XCTAssertEqual(URL(string: "http://localhost/new")!, visitDelegate.visitDidStartVisit?.location)
    }

    func test_errorResponseForTheMainFrame_failsTheVisit() throws {
        let visit = try coldBoot(path: "/missing")

        XCTAssertEqual(visit.state, .failed)
        XCTAssertTrue(visitDelegate.didCall("visit(_:requestDidFailWithError:)"))
    }

    func test_errorResponseForAnIframe_doesNotFailTheVisit() throws {
        let visit = try coldBoot(path: "/failing-iframe")

        XCTAssertEqual(visit.state, .started)
        XCTAssertFalse(visitDelegate.didCall("visit(_:requestDidFailWithError:)"))
    }

    /// Cold boots a page from the test server and waits for the request to finish.
    private func coldBoot(path: String) throws -> ColdBootVisit {
        let eventLoop = try SelectorEventLoop(selector: KqueueSelector())
        let server = DefaultHTTPServer.turboServer(eventLoop: eventLoop)
        try server.start()
        DispatchQueue.global().async { eventLoop.runForever() }
        addTeardownBlock {
            server.stopAndWait()
            eventLoop.stop()
        }

        let visit = ColdBootVisit(
            visitable: TestVisitable(url: URL(string: "http://localhost:8080\(path)")!),
            options: VisitOptions(),
            bridge: WebViewBridge(webView: WKWebView())
        )
        visit.delegate = visitDelegate
        visit.start()

        let finished = expectation(for: NSPredicate { _, _ in
            self.visitDelegate.didCall("visitRequestDidFinish(_:)")
        }, evaluatedWith: nil)
        wait(for: [finished], timeout: 10)

        return visit
    }
}
