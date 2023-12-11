import Hotwire
import SafariServices
import UIKit
import WebKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private let rootURL = Demo.current
    private lazy var navigator = TurboNavigator(pathConfiguration: pathConfiguration, delegate: self)

    // MARK: - Setup

    private func configureStrada() {
        Hotwire.registerStradaComponents([
            FormComponent.self,
            MenuComponent.self,
            OverflowMenuComponent.self,
        ])

        Turbo.config.makeCustomWebView = { configuration in
            configuration.defaultWebpagePreferences?.preferredContentMode = .mobile

            let webView = WKWebView(frame: .zero, configuration: configuration)
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
            // Initialize Strada bridge.
            Bridge.initialize(webView)

            return webView
        }
    }

    private func configureRootViewController() {
        guard let window = window else {
            fatalError()
        }

        window.rootViewController = navigator.rootViewController
    }

    // MARK: - Authentication

    private func promptForAuthentication() {
        let authURL = rootURL.appendingPathComponent("/signin")
        navigator.route(authURL)
    }

    // MARK: - Path Configuration

    private lazy var pathConfiguration = PathConfiguration(sources: [
        .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
    ])
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        configureStrada()
        configureRootViewController()

        navigator.route(rootURL)
    }
}

extension SceneController: TurboNavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        switch proposal.viewController {
        case NumbersViewController.pathConfigurationIdentifier:
            return .acceptCustom(NumbersViewController(url: proposal.url, navigator: navigator))

        case "numbersDetail":
            let alertController = UIAlertController(title: "Number", message: "\(proposal.url.lastPathComponent)", preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default, handler: nil))
            return .acceptCustom(alertController)

        default:
            return .acceptCustom(HotwireWebViewController(url: proposal.url))
        }
    }
}
