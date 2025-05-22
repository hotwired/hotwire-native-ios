import Foundation

public final class AppNavigationRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "app-navigation"

    public init() {}
    
    public func destination(for proposal: VisitProposal,
                            configuration: Navigator.Configuration,
                            navigator: Navigator) -> Router.Decision {
        
        if canHandle(proposal: proposal, configuration: configuration) {
            return .handleInAppDefaultWebViewController
        } else {
            return .willNotHandle
        }
    }
    
    private func canHandle(proposal: VisitProposal, configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() == proposal.url.host()
        }

        return configuration.startLocation.host == proposal.url.host
    }
}
