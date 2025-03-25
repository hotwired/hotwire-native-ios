import Foundation
import WebKit

/// A web view policy decision handler that intercepts navigation actions intended to reload the page.
///
/// When such an action is detected, it triggers a reload in the provided navigator
/// and cancels the default navigation action.
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
