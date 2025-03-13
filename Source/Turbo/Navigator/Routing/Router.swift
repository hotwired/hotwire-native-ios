import Foundation
import WebKit

public final class Router {
    let decisionHandlers: [RouteDecisionHandler]

    init(decisionHandlers: [RouteDecisionHandler]) {
        self.decisionHandlers = decisionHandlers
    }

    func decideRoute(for location: URL) -> Decision {
        for handler in decisionHandlers {
            if handler.matches(location: location) {
                handler.handle(location: location)
                return handler.decision
            }
        }

        return .cancel
    }

    func decidePolicy(for navigationAction: WKNavigationAction) -> WKNavigationActionPolicy {
        for handler in decisionHandlers {
            if handler.matches(navigationAction: navigationAction) {
                handler.handle(navigationAction: navigationAction)
                return handler.navigationActionPolicy
            }
        }

        return .allow
    }
}

public extension Router {
    enum Decision {
        case navigate
        case cancel
    }
}

public protocol RouteDecisionHandler {
    var name: String { get }
    var decision: Router.Decision { get }
    var navigationActionPolicy: WKNavigationActionPolicy { get }

    /// Determines whether the location matches this decision handler.
    /// Use your own custom rules based on the location's domain, protocol, path, or any other factors.
    /// - Parameter location: The location URL.
    /// - Returns: `true` if location matches this decision handler, `false` otherwise.
    func matches(location: URL) -> Bool

    /// Handle custom routing behavior when a match is found.
    /// For example, open an external browser or app for external domain urls.
    /// - Parameter location: The location URL.
    func handle(location: URL)

    func matches(navigationAction: WKNavigationAction) -> Bool
    func handle(navigationAction: WKNavigationAction)
}
