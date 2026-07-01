import Foundation
import WebKit

/// A web view policy decision handler that intercepts navigation actions
/// where the requested URL should be opened externally.
///
/// When such an action is detected, it routes the URL using the provided navigator
/// and cancels the web view's default navigation.
///
/// If the URL's scheme is considered invalid (e.g. `about`, `data`, `file`,
/// `javascript`), the navigation is simply cancelled without routing. This guards
/// against routing blank or unsafe URLs, such as those produced when a new window
/// request from an iframe is loaded into the web view.
public struct ExternalNavigationWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    public let name: String = "external-navigation-policy"

    /// URL schemes that should never be routed externally. Matching navigation
    /// actions are cancelled without routing.
    public let invalidSchemes: Set<String>

    public init(invalidSchemes: Set<String> = ["about", "data", "file", "javascript"]) {
        self.invalidSchemes = invalidSchemes
    }

    public func matches(navigationAction: WKNavigationAction,
                        configuration: Navigator.Configuration) -> Bool {
        return navigationAction.request.url != nil &&
        navigationAction.shouldOpenURLExternally
    }

    public func handle(navigationAction: WKNavigationAction,
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> WebViewPolicyManager.Decision {
        if let scheme = navigationAction.request.url?.scheme,
           invalidSchemes.contains(scheme) {
            return .cancel
        }

        if let url = navigationAction.request.url {
            navigator.route(url)
        }

        return .cancel
    }
}
