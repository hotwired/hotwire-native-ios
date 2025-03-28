import Foundation
import WebKit

/// A web view policy decision handler that intercepts navigation actions
/// where the requested URL should be opened externally.
///
/// When such an action is detected, it routes the URL using the provided navigator
/// and cancels the web view's default navigation.
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
