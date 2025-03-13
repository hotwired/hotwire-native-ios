import Foundation
import WebKit
import SafariServices

final class BrowserRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "browser"
    let decision: Router.Decision = .cancel
    let navigationActionPolicy: WKNavigationActionPolicy = .cancel

    func matches(location: URL) -> Bool {
        // TODO: Provide a base URL
        return true
    }

    func handle(location: URL, activeNavigationController: UINavigationController) {
        /// SFSafariViewController will crash if we pass along a URL that's not valid.
        guard location.scheme == "http" || location.scheme == "https" else { return }

        let safariViewController = SFSafariViewController(url: location)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }

        activeNavigationController.present(safariViewController, animated: true)
    }

    func matches(navigationAction: WKNavigationAction) -> Bool {
        return navigationAction.navigationType == .linkActivated
    }

    func handle(navigationAction: WKNavigationAction, activeNavigationController: UINavigationController) {
        // No-op.
    }
}
