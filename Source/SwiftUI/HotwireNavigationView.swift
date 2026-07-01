import SwiftUI
import UIKit

/// A SwiftUI view that wraps a single `Navigator` for stack-based navigation.
///
/// Use this as your root view in a SwiftUI app when you don't need tabs.
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
///             HotwireNavigationView(
///                 name: "main",
///                 startURL: URL(string: "https://example.com")!
///             )
///         }
///     }
/// }
/// ```
public struct HotwireNavigationView: UIViewControllerRepresentable {
    private let name: String
    private let startURL: URL
    private var navigatorDelegate: NavigatorDelegate?
    private var onNavigatorReady: ((Navigator) -> Void)?

    /// Creates a new Hotwire navigation view with a single navigator.
    /// - Parameters:
    ///   - name: A name for the navigator configuration (used internally).
    ///   - startURL: The initial URL to load.
    public init(name: String = "main", startURL: URL) {
        self.name = name
        self.startURL = startURL
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let configuration = Navigator.Configuration(name: name, startLocation: startURL)
        let navigator = Navigator(configuration: configuration, delegate: context.coordinator)
        context.coordinator.navigator = navigator
        navigator.start()

        // Notify that navigator is ready
        onNavigatorReady?(navigator)

        return navigator.rootViewController
    }

    public func updateUIViewController(_ controller: UINavigationController, context: Context) {
        // Update delegate reference if it changed
        context.coordinator.customDelegate = navigatorDelegate
        context.coordinator.onNavigatorReady = onNavigatorReady
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(customDelegate: navigatorDelegate, onNavigatorReady: onNavigatorReady)
    }

    // MARK: - Modifiers

    /// Sets a custom navigator delegate for handling visit proposals and errors.
    /// - Parameter delegate: The delegate to handle navigation events.
    /// - Returns: A modified view with the delegate set.
    public func navigatorDelegate(_ delegate: NavigatorDelegate) -> HotwireNavigationView {
        var copy = self
        copy.navigatorDelegate = delegate
        return copy
    }

    /// Provides access to the navigator when it becomes ready.
    /// - Parameter action: A closure called with the navigator.
    /// - Returns: A modified view that reports when the navigator is ready.
    public func onNavigatorReady(_ action: @escaping (Navigator) -> Void) -> HotwireNavigationView {
        var copy = self
        copy.onNavigatorReady = action
        return copy
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, NavigatorDelegate {
        var customDelegate: NavigatorDelegate?
        var onNavigatorReady: ((Navigator) -> Void)?
        var navigator: Navigator?

        init(customDelegate: NavigatorDelegate?, onNavigatorReady: ((Navigator) -> Void)?) {
            self.customDelegate = customDelegate
            self.onNavigatorReady = onNavigatorReady
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
