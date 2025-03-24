import Foundation
import WebKit

struct LinkActivatedWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "link activated policy"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        navigationAction.navigationType == .linkActivated &&
        navigationAction.isMainFrameNavigation
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        return .cancel
    }
}
