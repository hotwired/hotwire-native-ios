import WebKit

public enum Hotwire {
    /// Use this instance to configure Hotwire.
    public static var config = HotwireConfig()

    /// Registers your components with Strada to use with `HotwireWebViewController`.
    ///
    /// Use `Turbo.config.makeCustomWebView` to customize the web view or web view
    /// configuration further, making sure to call `Bridge.initialize()`.
    public static func registerStradaComponents(_ componentTypes: [BridgeComponent.Type]) {
        Turbo.config.defaultViewController = { url in
            HotwireWebViewController(url: url)
        }

        Turbo.config.userAgent += " \(Strada.userAgentSubstring(for: componentTypes))"
        stradaComponentTypes = componentTypes

        Turbo.config.makeCustomWebView = { configuration in
            configuration.defaultWebpagePreferences?.preferredContentMode = .mobile

            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.makeInspectableInDebugBuilds()
            Bridge.initialize(webView)
            return webView
        }
    }

    static var stradaComponentTypes = [BridgeComponent.Type]()
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
