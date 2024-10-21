import WebKit

public enum Hotwire {
    /// Use this instance to configure Hotwire.
    public static var config = HotwireConfig()

    /// Registers your bridge components to use with `HotwireWebViewController`.
    ///
    /// Use `Hotwire.config.makeCustomWebView` to customize the web view or web view
    /// configuration further, making sure to call `Bridge.initialize()`.
    public static func registerBridgeComponents(_ componentTypes: [BridgeComponent.Type]) {
        Hotwire.config.userAgent += " \(UserAgent.userAgentSubstring(for: componentTypes))"
        bridgeComponentTypes = componentTypes

        Hotwire.config.makeCustomWebView = { configuration in
            let webView = WKWebView.debugInspectable(configuration: configuration)
            Bridge.initialize(webView)
            return webView
        }

        NotificationCenter.default.postDidRegisterBridgeComponents()
    }

    static var bridgeComponentTypes = [BridgeComponent.Type]()
}
