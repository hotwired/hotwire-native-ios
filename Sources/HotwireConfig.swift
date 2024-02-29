import UIKit

public struct HotwireConfig {
    /// When enabled, adds a `UIBarButtonItem` of type `.done` to the left
    /// navigation bar button item on screens presented modally.
    public var showDoneButtonOnModals = false

    /// Sets the back button display mode of `HotwireWebViewController`.
    public var backButtonDisplayMode = UINavigationItem.BackButtonDisplayMode.default

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
