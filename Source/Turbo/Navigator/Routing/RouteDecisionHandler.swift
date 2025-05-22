import Foundation
import WebKit

/// An interface to implement to provide custom
/// route decision handling behaviors in your app.
public protocol RouteDecisionHandler {
    
    /// The decision handler name used in debug logging.
    var name: String { get }

    /// Returns whether this decision handler can handle this proposal (internally or externally) or whether another handler should handle it.
    ///
    /// - Parameters:
    ///   - proposal: the visit proposal
    ///   - configuration: The configuration of the navigator where the navigation is taking place.
    ///   - navigator: The navigator instance responsible for the navigation.
    /// - Returns: whether this decision handler will handle the proposal or not
    func destination(for proposal: VisitProposal,
                     configuration: Navigator.Configuration,
                     navigator: Navigator) -> Router.Decision
}
