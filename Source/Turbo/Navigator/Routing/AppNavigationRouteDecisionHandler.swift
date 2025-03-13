import Foundation
import WebKit

final class AppNavigationRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "app-navigation"
    let decision: Router.Decision = .navigate
    let navigationActionPolicy: WKNavigationActionPolicy = .cancel

    func matches(location: URL) -> Bool {
        // TODO: Provide a base URL
        return true
    }

    func handle(location: URL) {
        // No-op.
    }

    func matches(navigationAction: WKNavigationAction) -> Bool {
        return navigationAction.navigationType == .linkActivated
    }

    func handle(navigationAction: WKNavigationAction) {
        // No-op.
    }
}
