import Foundation
import WebKit

/// Routes location urls within in-app navigation or with custom behaviors
/// provided in `RouteDecisionHandler` instances.
public final class Router {
    let decisionHandlers: [RouteDecisionHandler]

    init(decisionHandlers: [RouteDecisionHandler]) {
        self.decisionHandlers = decisionHandlers
    }

    func decideRoute(for location: URL,
                     configuration: Navigator.Configuration,
                     navigator: Navigator) -> Decision {
        for handler in decisionHandlers {
            if handler.matches(location: location, configuration: configuration) {
                handler.handle(location: location,
                               configuration: configuration,
                               navigator: navigator)
                logger.debug("[Router] handler match found handler: \(handler.name) location: \(location)")
                return handler.decision
            }
        }

        logger.warning("[Router] no handler for location: \(location)")
        return .cancel
    }

    func decidePolicy(for navigationAction: WKNavigationAction,
                      configuration: Navigator.Configuration,
                      navigator: Navigator) -> WKNavigationActionPolicy {
        for handler in decisionHandlers {
            if handler.matches(navigationAction: navigationAction, configuration: configuration) {
                handler.handle(navigationAction: navigationAction,
                               configuration: configuration,
                               navigator: navigator)
                logger.debug("[Router] handler match found handler: \(handler.name) navigation action: \(navigationAction)")
                return handler.navigationActionPolicy
            }
        }

        logger.warning("[Router] no handler for navigation action: \(navigationAction)")
        return .allow
    }
}

public extension Router {
    enum Decision {
        /// Permit in-app navigation with your app's domain urls.
        case navigate
        /// Prevent in-app navigation. Always use this for external domain urls.
        case cancel
    }
}
