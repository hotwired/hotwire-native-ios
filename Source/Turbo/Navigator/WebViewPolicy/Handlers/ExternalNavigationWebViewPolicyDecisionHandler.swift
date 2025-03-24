import Foundation
import WebKit

struct ExternalNavigationWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "external-navigation-policy"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        return navigationAction.request.url != nil &&
        navigationAction.shouldOpenURLExternally
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        if let url = navigationAction.request.url {
            navigator.route(url)
        }

        return .cancel
    }
}
