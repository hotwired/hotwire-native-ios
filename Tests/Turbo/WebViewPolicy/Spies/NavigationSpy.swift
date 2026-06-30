@testable import HotwireNative
import Foundation
import UIKit
import WebKit

/// A lightweight `Navigating` test double that records navigation calls without
/// instantiating real `Session` or `WKWebView` instances.
final class NavigationSpy: Navigating {
    var routeWasCalled = false
    var routeURL: URL?
    var reloadWasCalled = false

    /// Stub for the currently displayed URL, overriding the `Navigating` default.
    var currentVisitableURL: URL?

    lazy var rootViewController = UINavigationController()
    lazy var modalRootViewController = UINavigationController()
    lazy var activeNavigationController = UINavigationController()
    lazy var activeWebView = WKWebView()

    func route(_ url: URL) {
        routeWasCalled = true
        routeURL = url
    }

    func route(_ proposal: VisitProposal) {
        routeWasCalled = true
        routeURL = proposal.url
    }

    func route(_ url: URL, options: VisitOptions?, parameters: [String: Any]?) {
        routeWasCalled = true
        routeURL = url
    }

    func pop(animated: Bool) {}

    func clearAll(animated: Bool) {}

    func reload() {
        reloadWasCalled = true
    }
}
