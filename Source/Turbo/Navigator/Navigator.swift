import Foundation
import SafariServices
import UIKit
import WebKit

class DefaultNavigatorDelegate: NSObject, NavigatorDelegate {}

/// Handles navigation to new URLs using the following rules:
/// [Navigator Handled Flows](https://native.hotwired.dev/reference/navigation)
public class Navigator {
    public weak var delegate: NavigatorDelegate?

    public var rootViewController: UINavigationController { hierarchyController.navigationController }
    public var modalRootViewController: UINavigationController { hierarchyController.modalNavigationController }
    public var activeNavigationController: UINavigationController { hierarchyController.activeNavigationController }
    public var activeWebView: WKWebView {
        if activeNavigationController == rootViewController {
            return session.webView
        }
        return modalSession.webView
    }
    public private(set) var session: Session
    public private(set) var modalSession: Session
    
    /// Set to handle customize behavior of the `WKUIDelegate`.
    ///
    /// Subclass `WKUIController` to add additional behavior alongside alert/confirm dialogs.
    /// Or, provide a completely custom `WKUIDelegate` implementation.
    public var webkitUIDelegate: WKUIDelegate? {
        didSet {
            session.webView.uiDelegate = webkitUIDelegate
            modalSession.webView.uiDelegate = webkitUIDelegate
        }
    }

    /// Convenience initializer that doesn't require manually creating `Session` instances.
    /// - Parameters:
    ///   - delegate: _optional:_ delegate to handle custom view controllers
    public convenience init(configuration: Navigator.Configuration, delegate: NavigatorDelegate? = nil) {
        let session = Session(webView: Hotwire.config.makeWebView())
        session.pathConfiguration = Hotwire.config.pathConfiguration

        let modalSession = Session(webView: Hotwire.config.makeWebView())
        modalSession.pathConfiguration = Hotwire.config.pathConfiguration

        self.init(session: session, modalSession: modalSession, delegate: delegate, configuration: configuration)
    }

    /// Routes to the start location provided in the `Navigator.Configuration`.
    public func start() {
        guard rootViewController.viewControllers.isEmpty,
        modalRootViewController.viewControllers.isEmpty else {
            logger.warning("Start can only be run when there are no view controllers on the stack.")
            return
        }

        route(configuration.startLocation)
    }

    /// Transforms `URL` -> `VisitProposal` -> `UIViewController`.
    /// Convenience function to routing a proposal directly.
    ///
    /// - Parameter url: the URL to visit
    /// - Parameter options: passed options will override default `advance` visit options
    /// - Parameter parameters: provide context relevant to `url`
    public func route(_ url: URL, options: VisitOptions? = VisitOptions(action: .advance), parameters: [String: Any]? = nil) {
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        route(VisitProposal(url: url, options: options ?? .init(action: .advance), properties: properties, parameters: parameters))
    }

    /// Transforms `VisitProposal` -> `UIViewController`
    /// Given the `VisitProposal`'s properties, push or present this view controller.
    ///
    /// - Parameter proposal: the proposal to visit
    public func route(_ proposal: VisitProposal) {
        if routeDecision(for: proposal.url) == .cancel {
            return
        }

        guard let controller = controller(for: proposal) else { return }
        hierarchyController.route(controller: controller, proposal: proposal)
    }

    /// Pops the top controller on the presented navigation stack.
    /// If a modal is presented with a single controller in the navigation
    /// stack then the modal is dismissed instead.
    /// - Parameter animated: Pass true to animate the presentation;
    /// otherwise, pass false.
    public func pop(animated: Bool = true) {
        hierarchyController.pop(animated: animated)
    }

    /// Dismisses a modally presented controller if present, then pops the
    /// entire navigation stack.
    /// - Parameter animated: Pass true to animate the presentation;
    /// otherwise, pass false.
    public func clearAll(animated: Bool = false) {
        hierarchyController.clearAll(animated: animated)
    }

    /// Reloads the main and modal `Session`.
    public func reload() {
        session.reload()
        modalSession.reload()
    }

    // MARK: Internal

    /// Modifies a UINavigationController according to visit proposals.
    lazy var hierarchyController = NavigationHierarchyController(delegate: self)

    /// Internal initializer requiring preconfigured `Session` instances.
    ///
    /// User `init(pathConfiguration:delegate:)` to only provide a `PathConfiguration`.
    /// - Parameters:
    ///   - session: the main `Session`
    ///   - modalSession: the `Session` used for the modal navigation controller
    ///   - delegate: _optional:_ delegate to handle custom view controllers
    init(session: Session,
         modalSession: Session,
         delegate: NavigatorDelegate? = nil,
         configuration: Navigator.Configuration) {
        self.session = session
        self.modalSession = modalSession
        self.configuration = configuration
        self.appLifecycleObserver = AppLifecycleObserver()

        self.delegate = delegate ?? navigatorDelegate

        self.session.delegate = self
        self.modalSession.delegate = self
        self.appLifecycleObserver.delegate = self

        self.webkitUIDelegate = WKUIController(delegate: self)
        session.webView.uiDelegate = webkitUIDelegate
        modalSession.webView.uiDelegate = webkitUIDelegate
    }

    // MARK: Private

    /// A default delegate implementation if none is provided.
    private let navigatorDelegate = DefaultNavigatorDelegate()
    private var backgroundTerminatedWebViewSessions = [Session]()
    private let configuration: Navigator.Configuration
    private let appLifecycleObserver: AppLifecycleObserver

    private func controller(for proposal: VisitProposal) -> UIViewController? {
        guard let delegate else {
            return nil
        }

        switch delegate.handle(proposal: proposal, from: self) {
        case .accept:
            return Hotwire.config.defaultViewController(proposal.url)
        case .acceptCustom(let customViewController):
            return customViewController
        case .reject:
            return nil
        }
    }

    private func routeDecision(for location: URL) -> Router.Decision {
        return Hotwire.config.router.decideRoute(
            for: location,
            configuration: configuration,
            navigator: self
        )
    }
}

// MARK: - SessionDelegate

extension Navigator: SessionDelegate {
    public func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        route(proposal)
    }

    public func session(_ session: Session, didProposeVisitToCrossOriginRedirect location: URL) {
        // Pop the current destination from the backstack since it
        // resulted in a visit failure due to a cross-origin redirect.
        pop(animated: false)
        route(location)
    }

    public func sessionDidStartFormSubmission(_ session: Session) {
        if let url = session.topmostVisitable?.initialVisitableURL {
            delegate?.formSubmissionDidStart(to: url)
        }
    }

    public func sessionDidFinishFormSubmission(_ session: Session) {
        if session == modalSession {
            self.session.markSnapshotCacheAsStale()
        }
        if let url = session.topmostVisitable?.initialVisitableURL {
            delegate?.formSubmissionDidFinish(at: url)
        }
    }

    public func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        delegate?.visitableDidFailRequest(visitable, error: error) {
            session.reload()
        }
    }

    public func session(_ session: Session, decidePolicyFor navigationAction: WKNavigationAction) -> WebViewPolicyManager.Decision {
        return Hotwire.config.webViewPolicyManager.decidePolicy(
            for: navigationAction,
            configuration: configuration,
            navigator: self
        )
    }

    public func sessionWebViewProcessDidTerminate(_ session: Session) {
        reloadIfPermitted(session)
    }

    public func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate?.didReceiveAuthenticationChallenge(challenge, completionHandler: completionHandler)
    }

    public func sessionDidFinishRequest(_ session: Session) {
        guard let url = session.activeVisitable?.initialVisitableURL else { return }

        Task { @MainActor in
            let cookies = await WKWebsiteDataStore.default().httpCookieStore.allCookies()
            HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: url)
            delegate?.requestDidFinish(at: url)
        }
    }

    public func sessionDidLoadWebView(_ session: Session) {
        session.webView.navigationDelegate = session
    }
}

// MARK: - NavigationHierarchyControllerDelegate

extension Navigator: NavigationHierarchyControllerDelegate {
    func visit(_ controller: Visitable, on navigationStack: NavigationHierarchyController.NavigationStackType, with options: VisitOptions) {
        switch navigationStack {
        case .main: session.visit(controller, options: options)
        case .modal: modalSession.visit(controller, options: options)
        }
    }
    
    func refreshVisitable(navigationStack: NavigationHierarchyController.NavigationStackType, newTopmostVisitable: any Visitable) {
        switch navigationStack {
        case .main:
            session.visit(newTopmostVisitable, action: .restore)
        case .modal:
            modalSession.visit(newTopmostVisitable, action: .restore)
        }
    }
}

extension Navigator: WKUIControllerDelegate {
    public func present(_ alert: UIAlertController, animated: Bool) {
        hierarchyController.activeNavigationController.present(alert, animated: animated)
    }
}

// MARK: - Session and web view reloading

extension Navigator {
    private func inspectAllSessions() {
        [session, modalSession].forEach { inspect($0) }
    }

    private func reloadIfPermitted(_ session: Session) {
        /// If the web view process is terminated, it leaves the web view with a white screen, so we need to reload it.
        /// However, if the web view is no longer onscreen, such as after visiting a page and going back to a native view,
        /// then reloading will unnecessarily fetch all the content, and on next visit,
        /// it will trigger various bridge messages since the web view will be added to the window and call all the connect() methods.
        ///
        /// We don't want to reload a view controller not on screen, since that can have unwanted
        /// side-effects for the next visit (like showing the wrong bridge components). We can't just
        /// check if the view controller is visible, since it may be further back in the stack of a navigation controller.
        /// Seeing if there is a parent was the best solution I could find.
        guard let viewController = session.activeVisitable?.visitableViewController,
              viewController.parent != nil
        else {
            return
        }

        // Don't reload the web view if the app is in the background.
        // Instead, save the session in `backgroundTerminatedWebViewSessions`
        // and reload it when the app is back in foreground.
        if appLifecycleObserver.appState == .background {
            backgroundTerminatedWebViewSessions.append(session)
            return
        }

        reload(session)
    }

    private func reload(_ session: Session) {
        session.reload()
    }

    /// Inspects the provided session to handle terminated web view process and reloads or recreates the web view accordingly.
    ///
    /// - Parameter session: The session to inspect.
    ///
    /// This method checks if the web view associated with the session has terminated in the background.
    /// If so, it removes the session from the list of background terminated web view processes, reloads the session, and returns.
    /// If the session's topmost visitable URL is not available, the method returns without further action.
    /// If the web view's content process state is non-recoverable/terminated, it recreates the web view for the session.
    private func inspect(_ session: Session) {
        if let index = backgroundTerminatedWebViewSessions.firstIndex(where: { $0 === session }) {
            backgroundTerminatedWebViewSessions.remove(at: index)
            reload(session)
            return
        }

        guard let _ = session.topmostVisitable?.initialVisitableURL else {
            return
        }

        session.webView.queryWebContentProcessState { [weak self] state in
            guard case .terminated = state else { return }
            self?.recreateWebView(for: session)
        }
    }

    /// Recreates the web view and session for the given session and performs a `replace` visit.
    ///
    /// - Parameter session: The session to recreate.
    private func recreateWebView(for session: Session) {
        guard let _ = session.activeVisitable?.visitableViewController,
              let url = session.activeVisitable?.initialVisitableURL else { return }

        let newSession = Session(webView: Hotwire.config.makeWebView())
        newSession.pathConfiguration = session.pathConfiguration
        newSession.delegate = self
        newSession.webView.uiDelegate = webkitUIDelegate

        if session == self.session {
            self.session = newSession
        } else {
            modalSession = newSession
        }

        let options = VisitOptions(action: .replace, response: nil)
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        route(VisitProposal(url: url, options: options, properties: properties))
    }
}

extension Navigator: AppLifecycleObserverDelegate {
    func appDidEnterBackground() {
        // No-op
    }

    func appWillEnterForeground() {
        inspectAllSessions()
    }
}
