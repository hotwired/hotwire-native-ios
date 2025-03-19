import Foundation
import WebKit
import SafariServices

final class BrowserRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "browser"
    let decision: Router.Decision = .cancel
    let navigationActionPolicy: WKNavigationActionPolicy = .cancel

    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() != location.host()
        }

        return configuration.startLocation.host != location.host
    }

    func handle(location: URL,
                configuration: Navigator.Configuration,
                navigator: Navigator) {
        open(externalURL: location,
             activeNavigationController: navigator.activeNavigationController)
    }

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        guard let url = navigationAction.request.url else {
            return false
        }

        return navigationAction.shouldOpenURLExternally &&
        matches(location: url, configuration: configuration)
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) {
        guard let url = navigationAction.request.url else {
            return
        }

        handle(location: url,
               configuration: configuration,
               navigator: navigator)
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

private extension WKNavigationAction {
    var shouldOpenURLExternally: Bool {
        return navigationType == .linkActivated ||
        (isMainFrameNavigation && navigationType == .other)
    }
}
