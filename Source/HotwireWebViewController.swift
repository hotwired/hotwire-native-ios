import UIKit
import WebKit

/// A base controller to use or subclass that handles bridge lifecycle callbacks.
/// Use `Hotwire.registerBridgeComponents(_:)` to register bridge components.
open class HotwireWebViewController: VisitableViewController, BridgeDestination {
    public lazy var bridgeDelegate = BridgeDelegate(
        location: visitableURL.absoluteString,
        destination: self,
        componentTypes: Hotwire.bridgeComponentTypes
    )

    // MARK: View lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonDisplayMode = Hotwire.config.backButtonDisplayMode
        view.backgroundColor = .systemBackground

        if Hotwire.config.showDoneButtonOnModals {
            addDoneButtonToModals()
        }

        bridgeDelegate.onViewDidLoad()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bridgeDelegate.onViewWillAppear()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bridgeDelegate.onViewDidAppear()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bridgeDelegate.onViewWillDisappear()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bridgeDelegate.onViewDidDisappear()
    }

    // MARK: Visitable

    override open func visitableDidActivateWebView(_ webView: WKWebView) {
        bridgeDelegate.webViewDidBecomeActive(webView)
    }

    override open func visitableDidDeactivateWebView() {
        bridgeDelegate.webViewDidBecomeDeactivated()
    }

    // MARK: Private

    private func addDoneButtonToModals() {
        if presentingViewController != nil {
            let action = UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: action)
        }
    }
}
