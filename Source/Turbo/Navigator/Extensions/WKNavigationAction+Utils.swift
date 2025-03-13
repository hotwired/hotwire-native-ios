import WebKit

extension WKNavigationAction {
    var isMainFrameNavigation: Bool {
        targetFrame?.isMainFrame ?? false
    }
}
