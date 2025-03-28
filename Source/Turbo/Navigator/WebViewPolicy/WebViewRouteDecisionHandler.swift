import Foundation
import WebKit

/// An interface to implement to provide custom
/// WebView policy decision handling behaviors in your app.
public protocol WebViewPolicyDecisionHandler {
    /// The decision handler name used in debug logging.
    var name: String { get }

    /// Determines whether this handler should process the given navigation action.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action to evaluate.
    ///   - configuration: The configuration of the navigator where the navigation is taking place.
    /// - Returns: `true` if the handler matches the navigation action; otherwise, `false`.
    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool

    /// Handles the navigation action if it matches this handler's criteria.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action to handle.
    ///   - configuration: The configuration of the navigator where the navigation is taking place.
    ///   - navigator: The navigator instance responsible for the navigation.
    /// - Returns: A decision, represented by a `WebViewPolicyManager.Decision`, indicating
    ///            whether to allow or cancel the WebView navigation.
    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision
}
