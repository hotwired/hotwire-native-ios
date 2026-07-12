import UIKit
import WebKit

open class VisitableViewController: UIViewController, Visitable {
    open weak var visitableDelegate: VisitableDelegate?
    open var appearReason: AppearReason = .pushedOntoNavigationStack
    open var disappearReason: DisappearReason = .poppedFromNavigationStack
    public let initialVisitableURL: URL
    public var currentVisitableURL: URL {
        resolveVisitableLocation()
    }

    public init(url: URL) {
        initialVisitableURL = url
        visitableLocationState = .initialized(url)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        installVisitableView()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appearReason == .tabSelected { return }
        visitableDelegate?.visitableViewWillAppear(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncLargeTitlePresentationAfterTransition()
        if appearReason == .tabSelected { return }
        visitableDelegate?.visitableViewDidAppear(self)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if disappearReason == .tabDeselected { return }
        visitableDelegate?.visitableViewWillDisappear(self)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if disappearReason == .tabDeselected { return }
        visitableDelegate?.visitableViewDidDisappear(self)
    }

    // MARK: Visitable

    open func visitableDidRender() {
        navigationItem.title = visitableView.webView?.title
        visitableLocationState = .resolved
        syncLargeTitlePresentationAfterTransition()
    }

    /// Adjusted top content inset sampled while a large-title bar is expanded,
    /// used to recognise (and repair) a bar that is stuck collapsed.
    private static var expandedTopContentInset: CGFloat?

    /// The web view activates before its view controller is pushed, and Turbo
    /// scrolls it during visits — including cache-restore renders that happen
    /// mid-transition against the outgoing page's geometry. UIKit derives the
    /// navigation bar's large-title state from that stale offset and locks the
    /// title collapsed; a collapsed bar resting at the top never re-expands
    /// without scrolling. Once any transition has settled, re-align the offset
    /// and, if the bar is stuck collapsed, drive the tracked offset to the
    /// sampled expanded top so the bar reopens. Real scroll positions (below
    /// the top) are left untouched.
    private func syncLargeTitlePresentationAfterTransition() {
        guard navigationController?.navigationBar.prefersLargeTitles == true,
              navigationItem.largeTitleDisplayMode != .never else { return }
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                self?.syncLargeTitlePresentation()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.syncLargeTitlePresentation()
            }
        }
    }

    private func syncLargeTitlePresentation() {
        // Only the settled, topmost controller may adjust the bar — an async
        // continuation from a page that was popped or covered must not restyle
        // the bar the next page now owns.
        guard navigationController?.topViewController == self,
              transitionCoordinator == nil,
              viewIfLoaded?.window != nil,
              navigationController?.navigationBar.prefersLargeTitles == true,
              navigationItem.largeTitleDisplayMode != .never,
              let scrollView = visitableView.webView?.scrollView else { return }

        let adjustedTop = scrollView.adjustedContentInset.top
        let top = -adjustedTop
        let atTop = scrollView.contentOffset.y <= top + 1

        if navigationItem.largeTitleDisplayMode == .always {
            if let expanded = Self.expandedTopContentInset, expanded > adjustedTop + 1, atTop {
                // Stuck collapsed at the top: UIKit only re-expands in response
                // to scrolling, so drive the tracked offset to the expanded
                // top; the bar and insets follow.
                scrollView.setContentOffset(CGPoint(x: 0, y: -expanded), animated: false)
                return
            }
            Self.expandedTopContentInset = max(Self.expandedTopContentInset ?? 0, adjustedTop)
        }

        // Align a web view resting between the raw and adjusted top (fresh
        // attach or post-render scroll reset).
        if scrollView.contentOffset.y > top, scrollView.contentOffset.y <= 0 {
            scrollView.setContentOffset(CGPoint(x: 0, y: top), animated: false)
        }
    }

    open func showVisitableActivityIndicator() {
        visitableView.showActivityIndicator()
    }

    open func hideVisitableActivityIndicator() {
        visitableView.hideActivityIndicator()
    }

    open func visitableDidActivateWebView(_ webView: WKWebView) {
        // No-op
    }

    open func visitableWillDeactivateWebView() {
        let webViewURL = visitableView.webView?.url
        let locationStateDescription = webViewURL != nil ? "webView's url: \(webViewURL!.absoluteString)" : "initialVisitableURL: \(initialVisitableURL.absoluteString)"
        logger.info("visitableWillDeactivateWebView: setting location state to \(locationStateDescription)")
        visitableLocationState = .deactivated(visitableView.webView?.url ?? initialVisitableURL)
    }

    open func visitableDidDeactivateWebView() {
        // No-op
    }

    // MARK: Private
    enum VisitableLocationState {
        case resolved
        case initialized(URL)
        case deactivated(URL)
    }

    private var visitableLocationState: VisitableLocationState

    // MARK: Visitable View

    open private(set) lazy var visitableView: VisitableView = {
        let view = VisitableView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func installVisitableView() {
        view.addSubview(visitableView)
        NSLayoutConstraint.activate([
            visitableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visitableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visitableView.topAnchor.constraint(equalTo: view.topAnchor),
            visitableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func resolveVisitableLocation() -> URL {
        switch visitableLocationState {
        case .resolved:
            if visitableView.webView?.url == nil {
                logger.info("Resolving visitable location to initialVisitableURL: \(initialVisitableURL.absoluteString)")
            }
            return visitableView.webView?.url ?? initialVisitableURL
        case .initialized(let url):
            return url
        case .deactivated(let url):
            return url
        }
    }
}

extension VisitableViewController {
    public enum AppearReason {
        case pushedOntoNavigationStack
        case revealedByPop
        case tabSelected
        case revealedByModalDismiss
    }

    public enum DisappearReason {
        case coveredByPush
        case poppedFromNavigationStack
        case tabDeselected
        case coveredByModal
    }
}
