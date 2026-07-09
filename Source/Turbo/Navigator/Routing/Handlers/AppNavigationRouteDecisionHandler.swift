import Foundation

public final class AppNavigationRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "app-navigation"

    public init() {}

    public func matches(proposal: VisitProposal,
                        configuration: Navigator.Configuration) -> Bool {
        let location = proposal.url

        /// Only HTTP(S) URLs can be routed in-app. A same-host URL with a custom
        /// scheme (e.g. `webcal://my.app.com/calendar.ics`) must fall through to
        /// `SystemNavigationRouteDecisionHandler` so the system can open it.
        guard location.scheme == "http" || location.scheme == "https" else {
            return false
        }

        if #available(iOS 16, *) {
            return configuration.startLocation.host() == location.host()
        }

        return configuration.startLocation.host == location.host
    }

    public func handle(proposal: VisitProposal,
                       configuration: Navigator.Configuration,
                       navigator: Navigating) -> Router.Decision {
        logger.info("Routing \(proposal.url.absoluteString)")
        return .navigate
    }
}
