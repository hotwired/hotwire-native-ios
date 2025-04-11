@testable import HotwireNative
import UIKit
import WebKit

class TestVisitable: UIViewController, Visitable {
    // MARK: - Tests

    var visitableDidRenderCalled = false
    var visitableDidActivateWebViewWasCalled = false
    var visitableDidDeactivateWebViewWasCalled = false
    var visitableWillDeactivateWebViewWasCalled = false

    // MARK: - Visitable

    var visitableDelegate: VisitableDelegate?
    var visitableView: VisitableView
    var initialVisitableURL: URL
    var currentVisitableURL: URL

    init(url: URL) {
        self.initialVisitableURL = url
        self.visitableView = VisitableView(frame: .zero)
        self.currentVisitableURL = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func visitableDidRender() {
        visitableDidRenderCalled = true
    }

    func visitableWillDeactivateWebView() {
        visitableWillDeactivateWebViewWasCalled = true
    }

    func visitableDidActivateWebView(_ webView: WKWebView) {
        visitableDidActivateWebViewWasCalled = true
    }

    func visitableDidDeactivateWebView() {
        visitableDidDeactivateWebViewWasCalled = true
    }
}

class TestSessionDelegate: NSObject, SessionDelegate {
    var sessionDidLoadWebViewCalled = false { didSet { didChange?() }}
    var sessionDidStartRequestCalled = false
    var sessionDidFinishRequestCalled = false
    var failedRequestError: Error? = nil
    var sessionDidFailRequestCalled = false { didSet { didChange?() }}
    var sessionDidProposeVisitCalled = false
    var sessionDidProposeVisitToCrossOriginRedirectWasCalled = false
    var sessionDidProposeVisitToCrossOriginRedirectLocation: URL?

    var didChange: (() -> Void)?

    func sessionDidLoadWebView(_ session: Session) {
        sessionDidLoadWebViewCalled = true
    }

    func sessionDidStartRequest(_ session: Session) {
        sessionDidStartRequestCalled = true
    }

    func sessionDidFinishRequest(_ session: Session) {
        sessionDidFinishRequestCalled = true
    }

    func sesssionDidStartFormSubmission(_ session: Session) {}

    func sessionDidFinishFormSubmission(_ session: Session) {}

    func sessionWebViewProcessDidTerminate(_ session: Session) {}

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        sessionDidFailRequestCalled = true
        failedRequestError = error
    }

    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        sessionDidProposeVisitCalled = true
    }

    func session(_ session: Session, didProposeVisitToCrossOriginRedirect location: URL) {
        sessionDidProposeVisitToCrossOriginRedirectWasCalled = true
        sessionDidProposeVisitToCrossOriginRedirectLocation = location
    }
}

class TestVisitDelegate {
    var methodsCalled: Set<String> = []
    var visitDidStartWasCalled = false
    var visitDidStartVisit: Visit?

    func didCall(_ method: String) -> Bool {
        methodsCalled.contains(method)
    }

    private func record(_ string: String = #function) {
        methodsCalled.insert(string)
    }
}

extension TestVisitDelegate: VisitDelegate {
    func visitDidInitializeWebView(_ visit: Visit) {
        record()
    }

    func visitWillStart(_ visit: Visit) {
        record()
    }

    func visitDidStart(_ visit: Visit) {
        record()
        visitDidStartWasCalled = true
        visitDidStartVisit = visit
    }

    func visitDidComplete(_ visit: Visit) {
        record()
    }

    func visitDidFail(_ visit: Visit) {
        record()
    }

    func visitDidFinish(_ visit: Visit) {
        record()
    }

    func visitWillLoadResponse(_ visit: Visit) {
        record()
    }

    func visitDidRender(_ visit: Visit) {
        record()
    }

    func visitRequestDidStart(_ visit: Visit) {
        record()
    }

    func visit(_ visit: Visit, requestDidFailWithError error: Error) {
        record()
    }

    func visitRequestDidFinish(_ visit: Visit) {
        record()
    }

    func visit(_ visit: Visit, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        record()
    }
}
