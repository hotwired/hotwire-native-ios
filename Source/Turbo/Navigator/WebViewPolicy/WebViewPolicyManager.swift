import Foundation
import WebKit

public final class WebViewPolicyManager {
    let policyDecisionHandlers: [WebViewPolicyDecisionHandler]

    init(policyDecisionHandlers: [WebViewPolicyDecisionHandler]) {
        self.policyDecisionHandlers = policyDecisionHandlers
    }

    func decidePolicy(for navigationAction: WKNavigationAction,
                      configuration: Navigator.Configuration,
                      navigator: Navigator) -> WebViewPolicyManager.Decision {
        for handler in policyDecisionHandlers {
            if handler.matches(navigationAction: navigationAction, configuration: configuration) {
                logger.debug("[WebViewPolicyManager] handler match found handler: \(handler.name) navigation action:\(navigationAction)")
                return handler.handle(navigationAction: navigationAction,
                                      configuration: configuration,
                                      navigator: navigator)
            }
        }

        logger.warning("[WebViewPolicyManager] no handler for navigation action: \(navigationAction)")
        return .allow
    }
}

public extension WebViewPolicyManager {
    enum Decision {
        case cancel
        case allow
    }
}
