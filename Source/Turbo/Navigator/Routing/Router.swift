import Foundation
import WebKit

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
                return handler.decision
            }
        }

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
