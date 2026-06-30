import Foundation
import UIKit

/// A testable abstraction over `Navigator`.
///
/// Refines `NavigationHandler` (which provides the `route` overloads) with the
/// navigation operations and view controller accessors that
/// `RouteDecisionHandler` and `WebViewPolicyDecisionHandler` implementations rely on.
public protocol Navigating: NavigationHandler {
    /// Pops the top controller on the presented navigation stack.
    func pop(animated: Bool)

    /// Dismisses a modally presented controller if present, then pops the entire navigation stack.
    func clearAll(animated: Bool)

    /// Reloads the main and modal `Session`.
    func reload()

    /// The root navigation controller of the main navigation stack.
    var rootViewController: UINavigationController { get }

    /// The root navigation controller of the modal navigation stack.
    var modalRootViewController: UINavigationController { get }

    /// The navigation controller currently presented to the user.
    var activeNavigationController: UINavigationController { get }

    /// The URL currently displayed by the top visitable on the active navigation stack, if any.
    var currentVisitableURL: URL? { get }
}

public extension Navigating {
    var currentVisitableURL: URL? {
        (activeNavigationController.topViewController as? VisitableViewController)?.currentVisitableURL
    }
}

extension Navigator: Navigating {}
