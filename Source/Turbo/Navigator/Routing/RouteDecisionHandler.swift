import Foundation
import WebKit

public protocol RouteDecisionHandler {
    var name: String { get }
    var decision: Router.Decision { get }
    var navigationActionPolicy: WKNavigationActionPolicy { get }

    /// Determines whether the location matches this decision handler.
    /// Use your own custom rules based on the location's domain, protocol, path, or any other factors.
    /// - Parameter location: The location URL.
    /// - Returns: `true` if location matches this decision handler, `false` otherwise.
    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool

    /// Handle custom routing behavior when a match is found.
    /// For example, open an external browser or app for external domain urls.
    /// - Parameter location: The location URL.
    func handle(location: URL,
                configuration: Navigator.Configuration,
                navigator: Navigator)

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator)
}
