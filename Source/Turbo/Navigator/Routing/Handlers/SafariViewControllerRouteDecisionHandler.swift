import Foundation
import SafariServices

/// Opens external URLs via an embedded `SafariViewController` so the user stays in-app.
/// NOTE: This will silently fail for a URL that's not `http` or `https`.
final class SafariViewControllerRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "safari"

    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() != location.host()
        }

        return configuration.startLocation.host != location.host
    }

    func handle(location: URL,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        open(externalURL: location,
             viewController: navigator.activeNavigationController)

        return .cancel
    }

    func open(externalURL: URL,
              viewController: UIViewController) {

        /// SFSafariViewController will crash if we pass along a URL that's not valid.
        guard externalURL.scheme == "http" || externalURL.scheme == "https" else { return }

        let safariViewController = SFSafariViewController(url: externalURL)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }

        viewController.present(safariViewController, animated: true)
    }
}
