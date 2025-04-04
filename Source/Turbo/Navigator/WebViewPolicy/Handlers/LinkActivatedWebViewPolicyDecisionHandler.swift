import Foundation
import WebKit

/// A web view policy decision handler that intercepts navigation actions
/// triggered by link activation in the main frame.
///
/// When such an action is detected, the handler cancels the navigation,
/// preventing the web view from following the link.
public struct LinkActivatedWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    public let name: String = "link-activated-policy"

    public init() {}

    public func matches(navigationAction: WKNavigationAction,
                        configuration: Navigator.Configuration) -> Bool {
        navigationAction.navigationType == .linkActivated &&
        navigationAction.isMainFrameNavigation
    }

    public func handle(navigationAction: WKNavigationAction,
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> WebViewPolicyManager.Decision {
        return .cancel
    }
}
