import UIKit
import WebKit

public struct HotwireConfig {
    /// When enabled, adds a `UIBarButtonItem` of type `.done` to the left
    /// navigation bar button item on screens presented modally.
    public var showDoneButtonOnModals = false

    /// Sets the back button display mode of `HotwireWebViewController`.
    public var backButtonDisplayMode = UINavigationItem.BackButtonDisplayMode.default

    // MARK: Turbo

    /// Override to set a custom user agent.
    /// - Important: Include "Turbo Native" to use `turbo_native_app?` on your Rails server.
    public var userAgent = "Turbo Native iOS" {
        didSet { Turbo.config.userAgent = userAgent }
    }

    /// The view controller used in `TurboNavigator` for web requests. Must be
    /// a `VisitableViewController` or subclass.
    public var defaultViewController: (URL) -> VisitableViewController = { url in
        VisitableViewController(url: url)
    } {
        didSet { Turbo.config.defaultViewController = defaultViewController }
    }

    /// Optionally customize the web views used by each Turbo Session.
    /// Ensure you return a new instance each time.
    public var makeCustomWebView: TurboConfig.WebViewBlock = { (configuration: WKWebViewConfiguration) in
        WKWebView(frame: .zero, configuration: configuration)
    } {
        didSet { Turbo.config.makeCustomWebView = makeCustomWebView }
    }

    /// Enable or disable debug logging for Turbo visits.
    public var turboDebugLoggingEnabled = false {
        didSet { Turbo.config.debugLoggingEnabled = turboDebugLoggingEnabled }
    }

    // MARK: Bridge

    /// Set a custom JSON encoder when parsing bridge payloads.
    /// The custom encoder can be useful when you need to apply specific
    /// encoding strategies, like snake case vs. camel case
    public var bridgeJsonEncoder = JSONEncoder() {
        didSet { Strada.config.jsonEncoder = bridgeJsonEncoder }
    }

    /// Set a custom JSON decoder when parsing bridge payloads.
    /// The custom encoder can be useful when you need to apply specific
    /// encoding strategies, like snake case vs. camel case
    public var bridgeJsonDecoder = JSONDecoder() {
        didSet { Strada.config.jsonDecoder = bridgeJsonDecoder }
    }

    /// Enable or disable debug logging for bridge elements connecting,
    /// disconnecting, receiving/sending messages, and more.
    public var bridgeDebugLoggingEnabled = false {
        didSet { Strada.config.debugLoggingEnabled = bridgeDebugLoggingEnabled }
    }
}
