import UIKit
import WebKit

open class VisitableViewController: UIViewController, Visitable {
    open weak var visitableDelegate: VisitableDelegate?
    open var visitableURL: URL!
    public var appearReason: AppearReason = .default

    public convenience init(url: URL) {
        self.init()
        self.visitableURL = url
    }

    // MARK: View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        installVisitableView()
    }

//    override open func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        visitableDelegate?.visitableViewWillAppear(self)
//    }

    open override func viewIsAppearing(_ animated: Bool) {
        super.viewWillAppear(animated)
        visitableDelegate?.visitableViewWillAppear(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visitableDelegate?.visitableViewDidAppear(self)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visitableDelegate?.visitableViewWillDisappear(self)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visitableDelegate?.visitableViewDidDisappear(self)
        appearReason = .default
    }

    // MARK: Visitable

    open func visitableDidRender() {
        title = visitableView.webView?.title
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

    open func visitableDidDeactivateWebView() {
        // No-op
    }

    // MARK: Visitable View

    open private(set) lazy var visitableView: VisitableView! = {
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
}

open class HotwireNavigationController: UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()

        super.delegate = delegateProxy
    }

    open override var delegate: UINavigationControllerDelegate? {
        get {
            return delegateProxy.originalDelegate
        }
        set {
            // Update the original delegate in the proxy.
            delegateProxy.setDelegate(newValue)
        }
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let visitableViewController = viewController as? VisitableViewController {
            visitableViewController.appearReason = .pushed
        }

        super.pushViewController(viewController, animated: animated)
    }

    open override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        if let visitableViewController = topViewController as? VisitableViewController {
            visitableViewController.appearReason = .poped
        }

        return poppedViewController
    }

    // MARK: Private
    private let delegateProxy = HotwireNavigationControllerDelegateProxy()
}

final class HotwireNavigationControllerDelegateProxy: NSObject, UINavigationControllerDelegate {
    weak var originalDelegate: UINavigationControllerDelegate?

    func setDelegate(_ delegate: UINavigationControllerDelegate?) {
        self.originalDelegate = delegate
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.tabBarController != nil,
           let visitableViewController = viewController as? VisitableViewController,
           visitableViewController.appearReason == .default {
            visitableViewController.appearReason = .tabSwitched
        }

        // Forward to the original delegate.
        originalDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Forward to the original delegate.
        originalDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    // TODO: Add other delegate methods
}
