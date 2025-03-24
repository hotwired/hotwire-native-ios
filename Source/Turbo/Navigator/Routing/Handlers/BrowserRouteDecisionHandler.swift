import Foundation
import WebKit
import SafariServices

final class BrowserRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "browser"

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
             activeNavigationController: navigator.activeNavigationController)

        return .cancel
    }

    /// Navigate to an external URL.
    ///
    /// - Parameters:
    ///   - externalURL: The URL to navigate to.
    ///   - activeNavigationController: The active navigation controller.
    public func open(externalURL: URL,
                     activeNavigationController: UINavigationController) {
        switch Hotwire.config.defaultExternalURLOpeningOption {
        case .system:
            UIApplication.shared.open(externalURL)

        case .safari:
            /// SFSafariViewController will crash if we pass along a URL that's not valid.
            guard externalURL.scheme == "http" || externalURL.scheme == "https" else { return }

            let safariViewController = SFSafariViewController(url: externalURL)
            safariViewController.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                safariViewController.preferredControlTintColor = .tintColor
            }

            activeNavigationController.present(safariViewController, animated: true)

        case .reject:
            return
        }
    }
}
