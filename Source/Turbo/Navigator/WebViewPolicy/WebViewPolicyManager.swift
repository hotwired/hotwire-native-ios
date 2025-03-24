import Foundation
import WebKit

/// Manages web view policy.
/// You can provide custom behaviors in `WebViewPolicyDecisionHandler` instances.
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
        // Cancel navigation to a webpage. Always use this when handling navigation yourself.
        case cancel
        // Allow navigation to a webpage.
        case allow
    }
}
