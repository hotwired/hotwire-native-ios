import WebKit

extension WKNavigationAction {
    var isMainFrameNavigation: Bool {
        targetFrame?.isMainFrame ?? false
    }

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
