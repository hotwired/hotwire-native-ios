import Foundation
import WebKit

public protocol WebViewPolicyDecisionHandler {
    var name: String { get }

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision
}
