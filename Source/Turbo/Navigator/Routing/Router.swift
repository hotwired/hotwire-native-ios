import Foundation
import WebKit

public final class Router {
    let decisionHandlers: [RouteDecisionHandler]

    init(decisionHandlers: [RouteDecisionHandler]) {
        self.decisionHandlers = decisionHandlers
    }

    func decideRoute(for location: URL,
                     configuration: Navigator.Configuration,
                     activeNavigationController: UINavigationController) -> Decision {
        for handler in decisionHandlers {
            if handler.matches(location: location, configuration: configuration) {
                handler.handle(location: location,
                               configuration: configuration,
                               activeNavigationController: activeNavigationController)
                return handler.decision
            }
        }

        return .cancel
    }

    func decidePolicy(for navigationAction: WKNavigationAction,
                      configuration: Navigator.Configuration,
                      activeNavigationController: UINavigationController) -> WKNavigationActionPolicy {
        for handler in decisionHandlers {
            if handler.matches(navigationAction: navigationAction, configuration: configuration) {
                handler.handle(navigationAction: navigationAction,
                               configuration: configuration,
                               activeNavigationController: activeNavigationController)
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
    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool

    /// Handle custom routing behavior when a match is found.
    /// For example, open an external browser or app for external domain urls.
    /// - Parameter location: The location URL.
    func handle(location: URL,
                configuration: Navigator.Configuration,
                activeNavigationController: UINavigationController)

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                activeNavigationController: UINavigationController)
}
