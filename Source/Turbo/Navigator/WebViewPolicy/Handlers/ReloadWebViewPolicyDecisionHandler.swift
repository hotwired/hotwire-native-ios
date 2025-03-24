import Foundation
import WebKit

struct ReloadWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "reload-policy"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        return navigationAction.shouldReloadPage
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        navigator.reload()

        return .cancel
    }
}
