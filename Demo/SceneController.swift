import HotwireNative
import SafariServices
import UIKit
import WebKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private let rootURL = Demo.current
    private lazy var navigator = TurboNavigator(pathConfiguration: pathConfiguration, delegate: self)

    // MARK: - Setup

    private func configureBridge() {
        Hotwire.registerBridgeComponents([
            FormComponent.self,
            MenuComponent.self,
            OverflowMenuComponent.self,
        ])
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

        configureBridge()
        configureRootViewController()

        navigator.route(rootURL)
    }
}

extension SceneController: TurboNavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        switch proposal.viewController {
        case NumbersViewController.pathConfigurationIdentifier:
            return .acceptCustom(NumbersViewController(url: proposal.url, navigator: navigator))

        case "numbers_detail":
            let alertController = UIAlertController(title: "Number", message: "\(proposal.url.lastPathComponent)", preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default, handler: nil))
            return .acceptCustom(alertController)

        default:
            return .acceptCustom(HotwireWebViewController(url: proposal.url))
        }
    }
}
