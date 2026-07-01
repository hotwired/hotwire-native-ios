@testable import HotwireNative
import WebKit
import XCTest

final class NavigatorRetryHandlerTests: XCTestCase {
    private var delegate: RetryCapturingNavigatorDelegate!
    private var session: RetryRecordingSessionSpy!
    private var navigator: Navigator!
    private let visitable = TestVisitable(url: URL(string: "https://example.com")!)

    override func setUp() {
        delegate = RetryCapturingNavigatorDelegate()
        session = RetryRecordingSessionSpy(webView: Hotwire.config.makeWebView())
        navigator = Navigator(
            session: session,
            modalSession: Session(webView: Hotwire.config.makeWebView()),
            delegate: delegate,
            configuration: .init(name: "", startLocation: URL(string: "https://example.com")!)
        )
    }

    /// A retry handler is now always provided, even for errors that were
    /// previously considered non-retryable (e.g. a 404).
    func test_didFailRequest_alwaysProvidesRetryHandler() {
        navigator.session(session, didFailRequestForVisitable: visitable, error: .http(.client(.notFound)))

        XCTAssertTrue(delegate.didFailRequestCalled)
        XCTAssertNotNil(delegate.capturedRetryHandler)
    }

    /// When there is no topmost visitable yet (e.g. a failed cold boot),
    /// `session.reload()` would no-op, so the handler retries the visit directly.
    func test_retryHandler_withNoTopmostVisitable_visitsVisitableWithReload() {
        session.stubbedTopmostVisitable = nil

        navigator.session(session, didFailRequestForVisitable: visitable, error: .http(.client(.notFound)))
        delegate.capturedRetryHandler?()

        XCTAssertEqual(session.visitWithReloadCallCount, 1)
        XCTAssertIdentical(session.visitedVisitable, visitable)
        XCTAssertEqual(session.reloadCallCount, 0)
    }

    /// When a topmost visitable exists, the handler reloads the session as before.
    func test_retryHandler_withTopmostVisitable_reloadsSession() {
        session.stubbedTopmostVisitable = visitable

        navigator.session(session, didFailRequestForVisitable: visitable, error: .http(.client(.notFound)))
        delegate.capturedRetryHandler?()

        XCTAssertEqual(session.reloadCallCount, 1)
        XCTAssertEqual(session.visitWithReloadCallCount, 0)
    }
}

// MARK: - Test doubles

private final class RetryCapturingNavigatorDelegate: NavigatorDelegate {
    private(set) var didFailRequestCalled = false
    private(set) var capturedRetryHandler: RetryBlock?

    func visitableDidFailRequest(_ visitable: Visitable, error: HotwireNativeError, retryHandler: RetryBlock?) {
        didFailRequestCalled = true
        capturedRetryHandler = retryHandler
    }
}

private final class RetryRecordingSessionSpy: Session {
    var stubbedTopmostVisitable: Visitable?
    private(set) var reloadCallCount = 0
    private(set) var visitWithReloadCallCount = 0
    private(set) var visitedVisitable: Visitable?

    override var topmostVisitable: Visitable? {
        stubbedTopmostVisitable
    }

    override func reload() {
        reloadCallCount += 1
    }

    override func visit(_ visitable: any Visitable, options: VisitOptions?, reload: Bool) {
        guard reload else { return }
        visitWithReloadCallCount += 1
        visitedVisitable = visitable
    }
}
