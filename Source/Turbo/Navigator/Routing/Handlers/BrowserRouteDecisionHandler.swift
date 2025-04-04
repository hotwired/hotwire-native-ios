import Foundation
import UIKit

/// Opens external URLs via `openURL(_:options:completionHandler)`.
public final class BrowserRouteDecisionHandler: RouteDecisionHandler {
    public let name: String = "browser"

    public init() {}

    public func matches(location: URL,
                        configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() != location.host()
        }

        return configuration.startLocation.host != location.host
    }

    public func handle(location: URL,
                       configuration: Navigator.Configuration,
                       navigator: Navigator) -> Router.Decision {
        UIApplication.shared.open(location)

        return .cancel
    }
}
