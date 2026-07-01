import SwiftUI

/// Return from `NavigatorDelegate.handle(proposal:from:)` to route a custom controller.
public enum ProposalResult: Equatable {
    /// Route a `VisitableViewController`.
    case accept

    /// Route a custom `UIViewController` or subclass.
    case acceptCustom(UIViewController)

    /// Do not route. Navigation is not modified.
    case reject

    /// Route a SwiftUI view wrapped in a `UIHostingController`.
    public static func accept<V: View>(_ view: V) -> ProposalResult {
        .acceptCustom(UIHostingController(rootView: view))
    }
}
