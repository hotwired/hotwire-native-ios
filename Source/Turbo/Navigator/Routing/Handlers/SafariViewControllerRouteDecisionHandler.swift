import Foundation
import SafariServices

/// Opens external URLs via an embedded `SafariViewController` so the user stays in-app.
public final class SafariViewControllerRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "safari"

    public init() {}

    public func matches(location: URL,
                        configuration: Navigator.Configuration) -> Bool {
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
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> HotwireNative.Router.Decision {
        Task { @MainActor in
            await open(externalURL: location,
                       viewController: navigator.activeNavigationController)
        }

        return .cancel
    }

    @MainActor
    func open(externalURL: URL,
              viewController: UIViewController) async {
        let didOpenAsUniversalLink = await openAsUniversalLink(
            externalURL: externalURL,
            viewController: viewController
        )

        if didOpenAsUniversalLink {
            return
        }

        openSafari(externalURL: externalURL, viewController: viewController)
    }

    @MainActor
    func openAsUniversalLink(externalURL: URL,
                             viewController: UIViewController) async -> Bool {
        let options = UIScene.OpenExternalURLOptions()
        options.universalLinksOnly = true

        guard let windowScene = viewController.view.window?.windowScene else {
            return false
        }

        return await windowScene.open(externalURL, options: options)
    }

    @MainActor
    func openSafari(externalURL: URL,
                    viewController: UIViewController) {
        let safariViewController = SFSafariViewController(url: externalURL)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }

        viewController.present(safariViewController, animated: true)
    }
}
