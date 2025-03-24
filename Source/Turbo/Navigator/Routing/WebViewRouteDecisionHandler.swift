import Foundation
import WebKit

public protocol WebViewPolicyDecisionHandler {
    var name: String { get }

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision
}

struct NewWindowWebViewRouteDecisionHandler: WebViewPolicyDecisionHandler {
    var name: String = "new window navigation"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        return navigationAction.request.url != nil &&
        navigationAction.navigationType == .linkActivated &&
        navigationAction.requestsNewWindow
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        guard let url = navigationAction.request.url else {
            return .cancel
        }

        navigator.route(url)

        return .cancel
    }
}

struct ReloadWebViewRouteDecisionHandler: WebViewPolicyDecisionHandler {
    var name: String = "reload"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        return navigationAction.shouldReloadPage
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        navigator.reload()

        return .cancel
    }
}

struct ExternalNavigationWebViewRouteDecisionHandler: WebViewPolicyDecisionHandler {
    var name: String = "external navigation"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        return navigationAction.request.url != nil &&
        navigationAction.shouldOpenURLExternally
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        guard let url = navigationAction.request.url else {
            return .cancel
        }

        navigator.route(url)

        return .cancel
    }
}

struct LinkActivatedWebViewRouteDecisionHandler: WebViewPolicyDecisionHandler {
    var name: String = "link activated"

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        navigationAction.navigationType == .linkActivated &&
        navigationAction.isMainFrameNavigation
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        return .cancel
    }
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
