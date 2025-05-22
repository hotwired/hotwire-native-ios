import Foundation
import UIKit

/// Opens external URLs via `openURL(_:options:completionHandler)`.
public final class SystemNavigationRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "system-navigation"

    public init() {}
    
    public func destination(for proposal: VisitProposal,
                            configuration: Navigator.Configuration,
                            navigator: Navigator) -> Router.Decision {
        if canHandle(proposal, configuration: configuration) {
            UIApplication.shared.open(proposal.url)
            return .intercept
        } else {
            return .willNotHandle
        }
    }
}

extension SystemNavigationRouteDecisionHandler {
    func canHandle(_ proposal: VisitProposal,
                   configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() != proposal.url.host()
        }

        return configuration.startLocation.host != proposal.url.host
    }
}
