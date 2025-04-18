import UIKit

/// Return from `NavigatorDelegate.handle(proposal:from:)` to route a custom controller.
public enum ProposalResult: Equatable {
    /// Route a `VisitableViewController`.
    case accept

    /// Route a custom `UIViewController` or subclass
    case acceptCustom(UIViewController)

    /// Do not route. Navigation is not modified.
    case reject
}
