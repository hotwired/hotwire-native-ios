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

extension WKNavigationAction {
    var shouldNavigateInApp: Bool {
        navigationType == .linkActivated ||
        isMainFrameNavigation
    }

    /// Indicates if the navigation action requests a new window (e.g., target="_blank").
    var requestsNewWindow: Bool {
        guard let targetFrame else { return true }
        return !targetFrame.isMainFrame
    }

    var shouldReloadPage: Bool {
        return isMainFrameNavigation && navigationType == .reload
    }

    var shouldOpenURLExternally: Bool {
        return navigationType == .linkActivated ||
        (isMainFrameNavigation && navigationType == .other)
    }
}
