import Foundation
import WebKit

/// A web view policy decision handler that intercepts navigation actions requesting a new window.
///
/// When such an action is detected, it routes the URL via the provided navigator
/// and cancels the default navigation action.
public struct NewWindowWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    public let name: String = "new-window-policy"

    public init() {}

    public func matches(navigationAction: WKNavigationAction,
                        configuration: Navigator.Configuration) -> Bool {
        return navigationAction.request.url != nil &&
        navigationAction.navigationType == .linkActivated &&
        navigationAction.requestsNewWindow
    }

    public func handle(navigationAction: WKNavigationAction,
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> WebViewPolicyManager.Decision {
        if let url = navigationAction.request.url {
            navigator.route(url)
        }

        return .cancel
    }
}
