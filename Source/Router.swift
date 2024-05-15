import Foundation

/// A protocol to bridge back to Hotwire world from a native context. Use this
/// to trigger a new page visit including routing and presentation.
///
/// When responding to `NavigatorDelegate.handle(proposal:)`, to route
/// a native view controller, pass in an instance of `Navigator` typed
/// as this protocol with an unowned reference. This ensures you avoid a
/// circular dependency between the two.
///
/// - Note: See `NumbersViewController` in the demo app for an example.
public protocol Router: AnyObject {
    func route(_ url: URL)

    func route(_ proposal: VisitProposal)
}

extension Navigator: Router {
    public func route(_ url: URL) {
        route(url, parameters: nil)
    }
}
