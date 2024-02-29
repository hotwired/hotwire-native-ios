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
    /// Use `Hotwire.config.makeCustomWebView` to customize the web view or web view
    /// configuration further, making sure to call `Bridge.initialize()`.
    public static func registerStradaComponents(_ componentTypes: [BridgeComponent.Type]) {
        Hotwire.config.defaultViewController = { url in
            HotwireWebViewController(url: url)
        }

        Hotwire.config.userAgent += " \(Strada.userAgentSubstring(for: componentTypes))"
        stradaComponentTypes = componentTypes

        Hotwire.config.makeCustomWebView = { configuration in
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
