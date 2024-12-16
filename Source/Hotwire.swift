import WebKit

public enum Hotwire {
    /// Use this instance to configure Hotwire.
    public static var config = HotwireConfig()

    /// Registers your bridge components to use with `HotwireWebViewController`.
    ///
    /// Use `Hotwire.config.makeCustomWebView` to customize the web view or web view
    /// configuration further, making sure to call `Bridge.initialize()`.
    public static func registerBridgeComponents(_ componentTypes: [BridgeComponent.Type]) {
        bridgeComponentTypes = componentTypes

        Hotwire.config.makeCustomWebView = { configuration in
            let webView = WKWebView.debugInspectable(configuration: configuration)
            Bridge.initialize(webView)
            return webView
        }
    }


    /// Loads the `PathConfiguration` JSON file(s) from the provided sources
    /// to configure navigation rules
    /// - Parameter sources: An array of `PathConfiguration.Source` objects representing
    ///   the sources to load.
    public static func loadPathConfiguration(from sources: [PathConfiguration.Source]) {
        config.pathConfiguration.sources = sources
    }

    static var bridgeComponentTypes = [BridgeComponent.Type]()
}
