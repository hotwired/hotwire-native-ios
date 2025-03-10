import Foundation
import WebKit

final class Router {
    let decisionHandlers: [RouteDecisionHandler]

    init(decisionHandlers: [RouteDecisionHandler]) {
        self.decisionHandlers = decisionHandlers
    }

    func decideRoute(for location: String) -> Decision {
        for handler in decisionHandlers {
            if handler.matches(location: location) {
                handler.handle(location: location)
                return handler.decision
            }
        }

        return .cancel
    }

//    func decidePolicy(for navigationAction: WKNavigationAction) -> WKNavigationActionPolicy {
//        for handler in decisionHandlers {
//
//        }
//    }
}

extension Router {
    enum Decision {
        case navigate
        case cancel
    }
}

protocol RouteDecisionHandler {
    var name: String { get }
    var decision: Router.Decision { get }

    func decidePolicy(for navigationAction: WKNavigationAction) -> WKNavigationActionPolicy

    /// Determines whether the location matches this decision handler.
    /// Use your own custom rules based on the location's domain, protocol, path, or any other factors.
    /// - Parameter location: <#location description#>
    /// - Returns: <#description#>
    func matches(location: String) -> Bool

    /// Handle custom routing behavior when a match is found.
    /// For example, open an external browser or app for external domain urls.
    /// - Parameter location: <#location description#>
    func handle(location: String)
}
