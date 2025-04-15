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
