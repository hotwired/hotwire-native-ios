import Foundation

public final class AppNavigationRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "app-navigation"

    public init() {}

    public func matches(location: URL,
                        configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() == location.host()
        }

        return configuration.startLocation.host == location.host
    }

    public func handle(location: URL,
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> Router.Decision {
        return .navigate
    }
}
