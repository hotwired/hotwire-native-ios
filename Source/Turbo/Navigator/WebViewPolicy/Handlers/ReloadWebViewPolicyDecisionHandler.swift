import Foundation
import WebKit

/// A web view policy decision handler that intercepts navigation actions intended to reload the page.
///
/// When such an action is detected, it triggers a reload in the provided navigator
/// and cancels the default navigation action.
public struct ReloadWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    public let name: String = "reload-policy"

    public init() {}

    public func matches(navigationAction: WKNavigationAction,
                        configuration: Navigator.Configuration) -> Bool {
        return navigationAction.shouldReloadPage
    }

    public func handle(navigationAction: WKNavigationAction,
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> WebViewPolicyManager.Decision {
        navigator.reload()

        return .cancel
    }
}
