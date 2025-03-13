import Foundation

/// Defines how external URLs should be opened. This enum is used in `BrowserRouteDecisionHandler`.
/// However, you can also write your own implementation for handling external URLs and reuse this enum.
public enum ExternalURLOpeningOption {
    /// Open via an embedded `SafariViewController` so the user stays in-app.
    /// NOTE: This will silently fail for a URL that's not `http` or `https`.
    case safari

    /// Open via `openURL(_:options:completionHandler)`.
    /// This is useful if the external URL is a deeplink.
    case system

    /// Will do nothing with the external URL.
    case reject
}
