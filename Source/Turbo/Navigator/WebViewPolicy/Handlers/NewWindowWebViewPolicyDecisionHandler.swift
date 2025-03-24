import Foundation
import WebKit

struct NewWindowWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "new window policy"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        return navigationAction.request.url != nil &&
        navigationAction.navigationType == .linkActivated &&
        navigationAction.requestsNewWindow
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
