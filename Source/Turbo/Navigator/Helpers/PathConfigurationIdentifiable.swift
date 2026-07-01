import Foundation

/// As a convenience, a view controller or SwiftUI view may conform to `PathConfigurationIdentifiable`.
///
/// Use a type's `pathConfigurationIdentifier` property instead of `proposal.url` when deciding how to handle a proposal.
///
/// ```swift
/// func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
///    switch proposal.viewController {
///    case RecipeViewController.pathConfigurationIdentifier:
///        return .acceptCustom(RecipeViewController())
///    case NumbersView.pathConfigurationIdentifier:
///        return .accept(NumbersView())
///    default:
///        return .accept
///    }
/// }
/// ```
/// - Note: See `VisitProposal.viewController` on how to use this in your configuration file.
public protocol PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { get }
}
