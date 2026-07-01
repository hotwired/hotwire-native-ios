import SwiftUI
import UIKit

/// A protocol for navigator delegates that need access to the tab bar controller.
///
/// Implement this protocol in your `NavigatorDelegate` if you need to access
/// the `HotwireTabBarController` for operations like authentication redirects.
public protocol HotwireTabBarControllerDelegate: AnyObject {
    var tabBarController: HotwireTabBarController? { get set }
}

/// A SwiftUI view that wraps `HotwireTabBarController` for tab-based navigation.
///
/// Use this as your root view in a SwiftUI app to get full Hotwire Native functionality
/// with multiple tabs.
///
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         Hotwire.loadPathConfiguration(from: ...)
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             HotwireRootView(tabs: [
///                 HotwireTab(title: "Home", url: URL(string: "https://example.com")!)
///             ])
///         }
///     }
/// }
/// ```
public struct HotwireRootView: UIViewControllerRepresentable {
    private let tabs: [HotwireTab]
    private var navigatorDelegate: NavigatorDelegate?
    private var onActiveNavigatorChange: ((Navigator) -> Void)?

    /// Creates a new Hotwire root view with the specified tabs.
    /// - Parameter tabs: The tabs to display in the tab bar.
    public init(tabs: [HotwireTab]) {
        self.tabs = tabs
    }

    public func makeUIViewController(context: Context) -> HotwireTabBarController {
        let controller = HotwireTabBarController(navigatorDelegate: context.coordinator)
        context.coordinator.tabBarController = controller

        // Provide tabBarController to delegates that need it
        if let tabBarDelegate = navigatorDelegate as? HotwireTabBarControllerDelegate {
            tabBarDelegate.tabBarController = controller
        }

        controller.load(tabs)
        return controller
    }

    public func updateUIViewController(_ controller: HotwireTabBarController, context: Context) {
        // Update delegate reference if it changed
        context.coordinator.customDelegate = navigatorDelegate
        context.coordinator.onActiveNavigatorChange = onActiveNavigatorChange

        // Ensure tabBarController reference is up to date
        if let tabBarDelegate = navigatorDelegate as? HotwireTabBarControllerDelegate {
            tabBarDelegate.tabBarController = controller
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(customDelegate: navigatorDelegate, onActiveNavigatorChange: onActiveNavigatorChange)
    }

    // MARK: - Modifiers

    /// Sets a custom navigator delegate for handling visit proposals and errors.
    /// - Parameter delegate: The delegate to handle navigation events.
    /// - Returns: A modified view with the delegate set.
    public func navigatorDelegate(_ delegate: NavigatorDelegate) -> HotwireRootView {
        var copy = self
        copy.navigatorDelegate = delegate
        return copy
    }

    /// Provides access to the active navigator when it changes.
    /// - Parameter action: A closure called with the active navigator.
    /// - Returns: A modified view that reports navigator changes.
    public func onActiveNavigatorChange(_ action: @escaping (Navigator) -> Void) -> HotwireRootView {
        var copy = self
        copy.onActiveNavigatorChange = action
        return copy
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, NavigatorDelegate {
        var customDelegate: NavigatorDelegate?
        var onActiveNavigatorChange: ((Navigator) -> Void)?
        weak var tabBarController: HotwireTabBarController?

        init(customDelegate: NavigatorDelegate?, onActiveNavigatorChange: ((Navigator) -> Void)?) {
            self.customDelegate = customDelegate
            self.onActiveNavigatorChange = onActiveNavigatorChange
        }

        // MARK: - NavigatorDelegate

        public func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
            customDelegate?.handle(proposal: proposal, from: navigator) ?? .accept
        }

        public func visitableDidFailRequest(_ visitable: Visitable, error: Error, retryHandler: RetryBlock?) {
            customDelegate?.visitableDidFailRequest(visitable, error: error, retryHandler: retryHandler)
        }

        public func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if let customDelegate {
                customDelegate.didReceiveAuthenticationChallenge(challenge, completionHandler: completionHandler)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }

        public func formSubmissionDidStart(to url: URL) {
            customDelegate?.formSubmissionDidStart(to: url)
        }

        public func formSubmissionDidFinish(at url: URL) {
            customDelegate?.formSubmissionDidFinish(at: url)
        }

        public func requestDidFinish(at url: URL) {
            customDelegate?.requestDidFinish(at: url)
        }
    }
}
