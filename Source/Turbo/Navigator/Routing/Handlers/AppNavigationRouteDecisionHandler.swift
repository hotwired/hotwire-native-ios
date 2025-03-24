import Foundation

final class AppNavigationRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "app-navigation"

    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() == location.host()
        }

        return configuration.startLocation.host == location.host
    }

    func handle(location: URL,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        return .navigate
    }
}
