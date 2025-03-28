import HotwireNative
import SafariServices
import UIKit
import WebKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private let rootURL = Demo.current
    private lazy var navigator = Navigator(
        configuration: .init(name: "main", startLocation: rootURL),
        delegate: self
    )

    // MARK: - Authentication

    private func promptForAuthentication() {
        let authURL = rootURL.appendingPathComponent("/signin")
        navigator.route(authURL)
    }
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()

        navigator.start()
    }
}

extension SceneController: NavigatorDelegate {
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

    func visitableDidFailRequest(_ visitable: any Visitable, error: any Error, retryHandler: RetryBlock?) {
        if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
            promptForAuthentication()
        } else if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                retryHandler?()
            }
        } else {
            let alert = UIAlertController(title: "Visit failed!", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            navigator.rootViewController.present(alert, animated: true)
        }
    }
}
