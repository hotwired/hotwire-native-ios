import Foundation
import UIKit

/// Routes location urls within in-app navigation or with custom behaviors
/// provided in `RouteDecisionHandler` instances.
public final class Router {
    let decisionHandlers: [RouteDecisionHandler]

    init(decisionHandlers: [RouteDecisionHandler]) {
        self.decisionHandlers = decisionHandlers
    }

    func decideRoute(for proposal: VisitProposal,
                     configuration: Navigator.Configuration,
                     navigator: Navigator) -> UIViewController? {
        
        for handler in decisionHandlers {
            let handlerResult = handler.destination(for: proposal,
                                                    configuration: configuration,
                                                    navigator: navigator)
            switch handlerResult {
                
            case .handleInAppDefaultWebViewController:
                return Hotwire.config.defaultViewController(proposal.url)
                
            case .handleInApp(let viewController):
                return viewController
                
            case .redirect(let newProposal):
                return decideRoute(for: newProposal,
                                   configuration: configuration,
                                   navigator: navigator)
                
            case .intercept:
                return nil
                
            case .willNotHandle:
                break
            }
        }

        logger.warning("[Router] no handler for proposal: \(proposal.url)")
        
        return nil
    }
}

public extension Router {
    enum Decision {
        
        // Handle in app with default controller
        case handleInAppDefaultWebViewController
        
        // The handler provides the next in-app destination.
        case handleInApp(UIViewController)
        
        // The handler is responsible, but will handle it without Hotwire Native.
        case intercept
        
        // The handler modified the proposal to reevaluate.
        case redirect(VisitProposal)
        
        // The handler is not responsible for this proposal.
        case willNotHandle
    }
}
