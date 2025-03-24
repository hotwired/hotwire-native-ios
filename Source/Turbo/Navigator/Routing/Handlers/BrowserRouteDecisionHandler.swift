import Foundation
import UIKit

final class BrowserRouteDecisionHandler: RouteDecisionHandler {
    let name: String = "browser"

    func matches(location: URL,
                 configuration: Navigator.Configuration) -> Bool {
        if #available(iOS 16, *) {
            return configuration.startLocation.host() != location.host()
        }

        return configuration.startLocation.host != location.host
    }

    func handle(location: URL,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> Router.Decision {
        UIApplication.shared.open(location)

        return .cancel
    }
}
