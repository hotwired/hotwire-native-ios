import Foundation

/// A protocol to bridge back to Turbo world from a native context. Use this
/// to trigger a new page visit including routing and presentation.
///
/// When responding to `TurboNavigatorDelegate.handle(proposal:)`, to route
/// a native view controller, pass in an instance of `TurboNavigator` typed
/// as this protocol with an unowned reference. This ensures you avoid a
/// circular dependency between the two.
///
/// - Note: See `NumbersViewController` in the demo app for an example.
public protocol Router: AnyObject {
    func route(_: URL)

    func route(_ proposal: VisitProposal)
}

extension TurboNavigator: Router {}
