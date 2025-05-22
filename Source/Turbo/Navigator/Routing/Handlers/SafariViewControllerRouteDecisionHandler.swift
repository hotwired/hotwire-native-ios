import Foundation
import SafariServices

/// Opens external URLs via an embedded `SafariViewController` so the user stays in-app.
public final class SafariViewControllerRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "safari"

    public init() {}
    
    public func destination(for proposal: VisitProposal,
                            configuration: Navigator.Configuration,
                            navigator: Navigator) -> Router.Decision {
        
        if canHandle(proposal, configuration: configuration) {
            open(externalURL: proposal.url,
                 viewController: navigator.activeNavigationController)
            return .intercept
        } else {
            return .willNotHandle
        }
    }
}

extension SafariViewControllerRouteDecisionHandler {
    
    private func canHandle(_ proposal: VisitProposal, configuration: Navigator.Configuration) -> Bool {
        /// SFSafariViewController will crash if we pass along a URL that's not valid.
        guard proposal.url.scheme == "http" || proposal.url.scheme == "https" else {
            return false
        }

        if #available(iOS 16, *) {
            return configuration.startLocation.host() != proposal.url.host()
        }

        return configuration.startLocation.host != proposal.url.host
    }
    
    private func open(externalURL: URL,
              viewController: UIViewController) {
        let safariViewController = SFSafariViewController(url: externalURL)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }

        viewController.present(safariViewController, animated: true)
    }
}
