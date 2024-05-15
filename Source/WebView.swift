import WebKit

extension WKWebView {
    static func debugInspectable(configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.makeInspectableInDebugBuilds()
        return webView
    }
}

private extension WKWebView {
    func makeInspectableInDebugBuilds() {
        #if DEBUG
            if #available(iOS 16.4, *) {
                isInspectable = true
            }
        #endif
    }
}
