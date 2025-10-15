import Foundation
import SafariServices

/// Opens external URLs via an embedded `SafariViewController` so the user stays in-app.
public final class SafariViewControllerRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "safari"
    private var openUniversalLinksInApp: Bool

    public init(openUniversalLinksInApp: Bool = false) {
        self.openUniversalLinksInApp = openUniversalLinksInApp
    }

    public func matches(location: URL,
                        configuration: Navigator.Configuration) -> Bool
    {
        /// SFSafariViewController will crash if we pass along a URL that's not valid.
        guard location.scheme == "http" || location.scheme == "https" else {
            return false
        }

        if #available(iOS 16, *) {
            return configuration.startLocation.host() != location.host()
        }

        return configuration.startLocation.host != location.host
    }

    public func handle(location: URL,
                       configuration _: Navigator.Configuration,
                       navigator: Navigator) -> Router.Decision
    {
        let openModal = { self.open(externalURL: location, viewController: navigator.activeNavigationController) }

        if openUniversalLinksInApp {
            UIApplication.shared.open(location, options: [.universalLinksOnly: true]) { success in
                if !success { openModal() }
            }
        } else {
            openModal()
        }

        return .cancel
    }

    func open(externalURL: URL,
              viewController: UIViewController)
    {
        let safariViewController = SFSafariViewController(url: externalURL)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }

        viewController.present(safariViewController, animated: true)
    }
}
