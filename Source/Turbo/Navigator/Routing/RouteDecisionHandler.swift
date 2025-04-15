import Foundation
import WebKit

/// An interface to implement to provide custom
/// route decision handling behaviors in your app.
public protocol RouteDecisionHandler {
    /// The decision handler name used in debug logging.
    var name: String { get }

    /// Determines whether the location matches this decision handler.
    /// Use your own custom rules based on the location's domain, protocol, path, or any other factors.
    /// - Parameters:
    ///     - location: The location URL.
    ///     - configuration: The configuration of the navigator where the navigation is taking place.
    /// - Returns: `true` if location matches this decision handler, `false` otherwise.
    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool

    /// Handle custom routing behavior when a match is found.
    /// For example, open an external browser or app for external domain urls.
    /// - Parameters:
    ///     - location: The location URL.
    ///     - configuration: The configuration of the navigator where the navigation is taking place.
    ///     - navigator: The navigator instance responsible for the navigation.
    func handle(location: URL,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision
}
