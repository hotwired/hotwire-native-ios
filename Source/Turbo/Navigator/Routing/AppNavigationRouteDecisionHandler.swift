import Foundation
import WebKit

final class AppNavigationRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "app-navigation"
    let decision: Router.Decision = .navigate
    let navigationActionPolicy: WKNavigationActionPolicy = .cancel

    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() == location.host()
        }

        return configuration.startLocation.host == location.host
    }

    func handle(location: URL,
                configuration: Navigator.Configuration,
                activeNavigationController: UINavigationController) {
        // No-op.
    }

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        guard let url = navigationAction.request.url else {
            return false
        }

        return navigationAction.navigationType == .linkActivated &&
        matches(location: url, configuration: configuration)
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                activeNavigationController: UINavigationController) {
        // No-op.
    }
}
