import Foundation
import WebKit

/// Routes location urls within in-app navigation or with custom behaviors
/// provided in `RouteDecisionHandler` instances.
public final class Router {
    let decisionHandlers: [RouteDecisionHandler]
    let webViewDecisionHandlers: [WebViewRouteDecisionHandler]

    init(decisionHandlers: [RouteDecisionHandler],
         webViewDecisionHandlers: [WebViewRouteDecisionHandler]) {
        self.decisionHandlers = decisionHandlers
        self.webViewDecisionHandlers = webViewDecisionHandlers
    }

    func decideRoute(for location: URL,
                     configuration: Navigator.Configuration,
                     navigator: Navigator) -> Decision {
        for handler in decisionHandlers {
            if handler.matches(location: location, configuration: configuration) {
                logger.debug("[Router] handler match found handler: \(handler.name) location: \(location)")
                return handler.handle(location: location,
                               configuration: configuration,
                               navigator: navigator)
            }
        }

        logger.warning("[Router] no handler for location: \(location)")
        return .cancel
    }

    func decidePolicy(for navigationAction: WKNavigationAction,
                      configuration: Navigator.Configuration,
                      navigator: Navigator) -> Decision {
        for handler in webViewDecisionHandlers {
            if handler.matches(navigationAction: navigationAction, configuration: configuration) {
                logger.debug("[Router] web handler match found handler: \(handler.name) navigation action:\(navigationAction)")
                return handler.handle(navigationAction: navigationAction,
                               configuration: configuration,
                               navigator: navigator)
            }
        }

        logger.warning("[Router] no web handler for navigation action: \(navigationAction)")
        return .navigate
    }
}

public extension Router {
    enum Decision {
        case navigate
        case cancel
    }
}
