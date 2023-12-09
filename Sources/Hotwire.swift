/// Re-expose packages under Hotwire namespace.
/// IMPORTANT: `@_exported` is not yet stable.
@_exported import Strada
@_exported import Turbo

import WebKit

public enum Hotwire {
    /// Use this instance to configure Hotwire.
    public static var config = HotwireConfig()

    /// Registers your components with Strada to use with `HotwireWebViewController`.
    ///
    /// Use `Turbo.config.makeCustomWebView` to customize the web view or web view
    /// configuration further, making sure to call `Bridge.initialize()`.
    public static func registerStradaComponents(_ componentTypes: [BridgeComponent.Type]) {
        Turbo.config.userAgent += " \(Strada.userAgentSubstring(for: componentTypes))"
        stradaComponentTypes = componentTypes

        Turbo.config.makeCustomWebView = { configuration in
            let webView = WKWebView(frame: .zero, configuration: configuration)
            Bridge.initialize(webView)
            return webView
        }
    }

    static var stradaComponentTypes = [BridgeComponent.Type]()
}
