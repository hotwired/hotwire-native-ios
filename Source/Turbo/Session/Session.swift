import UIKit
import WebKit

/// A Session represents the main interface for managing
/// a Hotwire app in a web view. Each Session manages a single web view
/// so you should create multiple sessions to have multiple web views, for example
/// when using modals or tabs
public class Session: NSObject {
    public weak var delegate: SessionDelegate?

    public let webView: WKWebView
    public var pathConfiguration: PathConfiguration?

    private lazy var bridge = WebViewBridge(webView: webView)
    private var initialized = false
    private var refreshing = false

    private var isShowingStaleContent = false
    private var isSnapshotCacheStale = false

    /// Automatically creates a web view with the passed-in configuration
    public convenience init(webViewConfiguration: WKWebViewConfiguration? = nil) {
        self.init(webView: WKWebView(frame: .zero, configuration: webViewConfiguration ?? WKWebViewConfiguration()))
    }

    public init(webView: WKWebView) {
        self.webView = webView
        super.init()
        setup()
    }

    private func setup() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        bridge.delegate = self
    }

    // MARK: Visiting

    private var currentVisit: Visit?
    private var topmostVisit: Visit?
    private var previousVisit: Visit?

    /// The topmost visitable is the visitable that has most recently completed a visit
    public var topmostVisitable: Visitable? {
        topmostVisit?.visitable
    }

    /// The active visitable is the visitable that currently owns the web view
    public var activeVisitable: Visitable? {
        activatedVisitable
    }

    public func visit(_ visitable: Visitable, action: VisitAction) {
        visit(visitable, options: VisitOptions(action: action, response: nil))
    }

    public func visit(_ visitable: Visitable, options: VisitOptions? = nil, reload: Bool = false) {
        guard visitable.visitableURL != nil else {
            fatalError("Visitable must provide a url!")
        }

        visitable.visitableDelegate = self

        if reload {
            initialized = false
        }

        let visit = makeVisit(for: visitable, options: options ?? VisitOptions())
        currentVisit?.cancel()
        currentVisit = visit

        log("visit", ["location": visit.location, "options": visit.options, "reload": reload])

        visit.delegate = self
        visit.start()
    }

    private func makeVisit(for visitable: Visitable, options: VisitOptions) -> Visit {
        if initialized {
            return JavaScriptVisit(visitable: visitable, options: options, bridge: bridge, restorationIdentifier: restorationIdentifier(for: visitable))
        } else {
            return ColdBootVisit(visitable: visitable, options: options, bridge: bridge)
        }
    }

    public func reload() {
        guard let visitable = topmostVisitable else { return }

        initialized = false
        visit(visitable)
        topmostVisit = currentVisit
    }

    public func clearSnapshotCache() {
        bridge.clearSnapshotCache()
    }

    // MARK: Caching

    /// Clear the snapshot cache the next time the visitable view appears.
    public func markSnapshotCacheAsStale() {
        isSnapshotCacheStale = true
    }

    /// Reload the `Session` the next time the visitable view appears.
    public func markContentAsStale() {
        isShowingStaleContent = true
    }

    // MARK: Visitable activation

    private var activatedVisitable: Visitable?

    private func activateVisitable(_ visitable: Visitable) {
        guard !isActivatedVisitable(visitable) else { return }

        deactivateActivatedVisitable()
        visitable.activateVisitableWebView(webView)
        activatedVisitable = visitable
    }

    private func deactivateActivatedVisitable() {
        guard let visitable = activatedVisitable else { return }
        deactivateVisitable(visitable, showScreenshot: true)
    }

    private func deactivateVisitable(_ visitable: Visitable, showScreenshot: Bool = false) {
        guard isActivatedVisitable(visitable) else { return }

        if showScreenshot {
            visitable.updateVisitableScreenshot()
            visitable.showVisitableScreenshot()
        }

        visitable.deactivateVisitableWebView()
        activatedVisitable = nil
    }

    private func isActivatedVisitable(_ visitable: Visitable) -> Bool {
        return visitable === activatedVisitable
    }

    // MARK: Restoration Identifiers

    private var visitableRestorationIdentifiers = NSMapTable<UIViewController, NSString>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: [])

    private func restorationIdentifier(for visitable: Visitable) -> String? {
        return visitableRestorationIdentifiers.object(forKey: visitable.visitableViewController) as String?
    }

    private func storeRestorationIdentifier(_ restorationIdentifier: String, forVisitable visitable: Visitable) {
        visitableRestorationIdentifiers.setObject(restorationIdentifier as NSString, forKey: visitable.visitableViewController)
    }

    // MARK: - Navigation

    private func completeNavigationForCurrentVisit() {
        guard let visit = currentVisit else { return }

        topmostVisit = visit
    }
}

extension Session: VisitDelegate {
    func visitRequestDidStart(_ visit: Visit) {
        delegate?.sessionDidStartRequest(self)
    }

    func visitRequestDidFinish(_ visit: Visit) {
        delegate?.sessionDidFinishRequest(self)
    }

    func visit(_ visit: Visit, requestDidFailWithError error: Error) {
        delegate?.session(self, didFailRequestForVisitable: visit.visitable, error: error)
    }

    func visitDidInitializeWebView(_ visit: Visit) {
        initialized = true
        delegate?.sessionDidLoadWebView(self)
    }

    func visitWillStart(_ visit: Visit) {
        guard !visit.isPageRefresh else { return }

        visit.visitable.showVisitableScreenshot()
        activateVisitable(visit.visitable)
    }

    func visitDidStart(_ visit: Visit) {
        guard !visit.hasCachedSnapshot else { return }
        guard !visit.isPageRefresh else { return }

        visit.visitable.showVisitableActivityIndicator()
    }

    func visitWillLoadResponse(_ visit: Visit) {
        visit.visitable.updateVisitableScreenshot()
        visit.visitable.showVisitableScreenshot()
    }

    func visitDidRender(_ visit: Visit) {
        visit.visitable.hideVisitableScreenshot()
        visit.visitable.hideVisitableActivityIndicator()
        visit.visitable.visitableDidRender()
    }

    func visitDidComplete(_ visit: Visit) {
        guard let restorationIdentifier = visit.restorationIdentifier else { return }
        storeRestorationIdentifier(restorationIdentifier, forVisitable: visit.visitable)
    }

    func visitDidFail(_ visit: Visit) {
        visit.visitable.clearVisitableScreenshot()
        visit.visitable.showVisitableScreenshot()
        visit.visitable.hideVisitableActivityIndicator()
    }

    func visitDidFinish(_ visit: Visit) {
        guard refreshing else { return }

        refreshing = false
        visit.visitable.visitableDidRefresh()
    }

    func visit(_ visit: Visit, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate?.session(self, didReceiveAuthenticationChallenge: challenge, completionHandler: completionHandler)
    }
}

extension Session: VisitableDelegate {
    public func visitableViewWillAppear(_ visitable: Visitable) {
        defer {
            /// Nilling out the previous visit here prevents `double-snapshotting` for web -> web visits.
            previousVisit = nil
        }

        guard let topmostVisit, let currentVisit else { return }

        if isSnapshotCacheStale {
            clearSnapshotCache()
            isSnapshotCacheStale = false
        }

        if isShowingStaleContent {
            reload()
            isShowingStaleContent = false
            return
        }

        // Back swipe gesture canceled.
        if visitable === topmostVisit.visitable && visitable.visitableViewController.isMovingToParent {
            if topmostVisit.state == .completed {
                currentVisit.cancel()
            } else {
                visit(visitable, action: .advance)
            }
            return
        }

        // Navigating forward - complete navigation early.
        if visitable === currentVisit.visitable {
            let currentVisitHasResponse = currentVisit.options.response?.responseHTML != nil
            
            /// Most visits will be `.started` here, but form submission redirects containing `response.responseHTML` in
            /// the modal context while navigating back to the default context will already be `.completed` at this point.
            if currentVisit.state == .started || (currentVisitHasResponse && currentVisit.state == .completed) {
                completeNavigationForCurrentVisit()
                return
            }
        }

        // Navigating backward from a web view screen to a web view screen.
        if visitable !== topmostVisit.visitable {
            visit(visitable, action: .restore)
            return
        }

        // Navigating backward from a native to a web view screen.
        if visitable === previousVisit?.visitable {
            visit(visitable, action: .restore)
        }
    }

    public func visitableViewDidAppear(_ visitable: Visitable) {
        if let currentVisit = currentVisit, visitable === currentVisit.visitable {
            // Appearing after successful navigation
            completeNavigationForCurrentVisit()
            if currentVisit.state != .failed {
                activateVisitable(visitable)
            }
        } else if let topmostVisit = topmostVisit, visitable === topmostVisit.visitable && topmostVisit.state == .completed {
            // Reappearing after canceled navigation
            visit(visitable, action: .restore)
        }
    }

    public func visitableViewWillDisappear(_ visitable: Visitable) {
        previousVisit = topmostVisit
    }

    public func visitableViewDidDisappear(_ visitable: Visitable) {
        previousVisit?.cacheSnapshot()
        deactivateVisitable(visitable)
    }

    public func visitableDidRequestReload(_ visitable: Visitable) {
        guard visitable === topmostVisitable else { return }
        reload()
    }

    public func visitableDidRequestRefresh(_ visitable: Visitable) {
        guard visitable === topmostVisitable else { return }

        refreshing = true
        visitable.visitableWillRefresh()
        reload()
    }
}

extension Session: WebViewDelegate {
    func webView(_ bridge: WebViewBridge, didProposeVisitToLocation location: URL, options: VisitOptions) {
        let properties = pathConfiguration?.properties(for: location) ?? [:]
        let proposal = VisitProposal(url: location, options: options, properties: properties)
        delegate?.session(self, didProposeVisit: proposal)
    }

    func webView(_ webView: WebViewBridge, didStartFormSubmissionToLocation location: URL) {
        delegate?.sessionDidStartFormSubmission(self)
    }

    func webView(_ webView: WebViewBridge, didFinishFormSubmissionToLocation location: URL) {
        delegate?.sessionDidFinishFormSubmission(self)
    }

    func webViewDidInvalidatePage(_ bridge: WebViewBridge) {
        guard let visitable = topmostVisitable else { return }

        visitable.updateVisitableScreenshot()
        visitable.showVisitableScreenshot()
        visitable.showVisitableActivityIndicator()
        reload()
    }

    /// Initial page load failed, this will happen when we couldn't find Turbo JS on the page
    func webView(_ webView: WebViewBridge, didFailInitialPageLoadWithError error: Error) {
        guard let currentVisit = currentVisit, !initialized else { return }

        initialized = false
        currentVisit.cancel()
        visitDidFail(currentVisit)
        visit(currentVisit, requestDidFailWithError: error)
    }

    func webView(_ bridge: WebViewBridge, didFailJavaScriptEvaluationWithError error: Error) {
        guard let currentVisit = currentVisit, initialized else { return }

        initialized = false
        currentVisit.cancel()
        visit(currentVisit.visitable)
    }

    /// Called by the Turbo bridge when a visit request fails with a non-HTTP status code,
    /// suggesting it may be the result of a cross-origin redirect visit.
    ///
    /// Determining a cross-origin redirect is not possible in JavaScript using the Fetch API
    /// due to CORS restrictions, so verification is performed on the native side.
    /// If a redirect is detected, a cross-origin redirect visit is proposed; otherwise,
    /// the visit is failed.
    ///
    /// - Parameters:
    ///   - webView: The web view bridge.
    ///   - location: The original visit location requested.
    ///   - identifier: A unique identifier for the visit.
    func webView(_ webView: WebViewBridge, didFailRequestWithNonHttpStatusToLocation location: URL, identifier: String) {
        log("didFailRequestWithNonHttpStatusToLocation",
            ["location": location,
             "visitIdentifier": identifier]
        )

        Task {
            await resolveRedirect(to: location, identifier: identifier)
        }
    }

    private func resolveRedirect(to location: URL, identifier: String) async {
        do {
            let result = try await RedirectHandler().resolve(location: location)
            switch result {
            case .noRedirect:
                log("resolveRedirect: no redirect",
                    ["location": location,
                     "visitIdentifier": identifier]
                )
                await failCurrentVisit(
                    with: TurboError.http(statusCode: 0),
                    visitIdentifier: identifier
                )
            case .sameOriginRedirect(let url):
                // Same-domain redirects are handled by Turbo.
                // Handling them here could lead to an infinite loop.
                log("resolveRedirect: same domain redirect",
                    ["location": location,
                     "redirectLocation": url,
                     "visitIdentifier": identifier]
                )
                await failCurrentVisit(
                    with: TurboError.http(statusCode: 0),
                    visitIdentifier: identifier
                )
            case .crossOriginRedirect(let url):
                await visitProposedToCrossOriginRedirect(
                    location: location,
                    redirectLocation: url,
                    visitIdentifier: identifier
                )
            }
        } catch {
            await failCurrentVisit(
                with: error,
                visitIdentifier: identifier
            )
        }
    }

    @MainActor
    private func failCurrentVisit(with error: Error, visitIdentifier: String) {
        // This is only relevant to `JavaScriptVisit`, as `ColdBootVisit` currently
        // doesn't go through the same flow.
        guard let visit = currentVisit as? JavaScriptVisit,
              visit.identifier == visitIdentifier else { return }

        visit.fail(with: error)
    }

    @MainActor
    private func visitProposedToCrossOriginRedirect(
        location: URL,
        redirectLocation: URL,
        visitIdentifier: String) {
        log("visitProposedToCrossOriginRedirect",
            ["location": location,
             "redirectLocation": redirectLocation,
             "visitIdentifier": visitIdentifier]
        )

        guard let visit = currentVisit as? JavaScriptVisit,
              visit.identifier == visitIdentifier else { return }

        delegate?.session(self, didProposeVisitToCrossOriginRedirect: redirectLocation)
    }
}

extension Session: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navigationDecision = NavigationDecision(navigationAction: navigationAction)
        decisionHandler(navigationDecision.policy)

        if let url = navigationDecision.externallyOpenableURL {
            openExternalURL(url)
        } else if navigationDecision.shouldReloadPage {
            reload()
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        log("webViewWebContentProcessDidTerminate")
        delegate?.sessionWebViewProcessDidTerminate(self)
    }

    private func openExternalURL(_ url: URL) {
        log("openExternalURL", ["url": url])
        delegate?.session(self, openExternalURL: url)
    }

    private struct NavigationDecision {
        let navigationAction: WKNavigationAction

        var policy: WKNavigationActionPolicy {
            navigationAction.navigationType == .linkActivated || isMainFrameNavigation ? .cancel : .allow
        }

        var externallyOpenableURL: URL? {
            if let url = navigationAction.request.url, shouldOpenURLExternally {
                return url
            } else {
                return nil
            }
        }

        var shouldOpenURLExternally: Bool {
            let type = navigationAction.navigationType
            return type == .linkActivated || (isMainFrameNavigation && type == .other)
        }

        var shouldReloadPage: Bool {
            let type = navigationAction.navigationType
            return isMainFrameNavigation && type == .reload
        }

        var isMainFrameNavigation: Bool {
            navigationAction.targetFrame?.isMainFrame ?? false
        }
    }
}

private func log(_ name: String, _ arguments: [String: Any] = [:]) {
    logger.debug("[Session] \(name) \(arguments)")
}
