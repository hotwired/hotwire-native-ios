@testable import HotwireNative
import Foundation

final class NavigationSpy: Navigator {
    var routeWasCalled = false
    var routeURL: URL?
    var reloadWasCalled = false

    init(configuration: Navigator.Configuration) {
        super.init(
            session: Session(webView: Hotwire.config.makeWebView()),
            modalSession: Session(webView: Hotwire.config.makeWebView()),
            configuration: configuration
        )
    }

    override func route(_ url: URL, options: VisitOptions? = VisitOptions(action: .advance), parameters: [String : Any]? = nil) {
        routeWasCalled = true
        routeURL = url
    }

    override func reload() {
        reloadWasCalled = true
    }
}
