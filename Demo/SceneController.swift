import HotwireNative
import SafariServices
import UIKit
import WebKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private let rootURL = Demo.current
    private var navigators = [Navigator]()
    private let tabBarController = UITabBarController()
    private var activeNavigator: Navigator {
        navigators[tabBarController.selectedIndex]
    }

    // MARK: - Authentication

    private func promptForAuthentication() {
        let authURL = rootURL.appendingPathComponent("/signin")
        navigators[tabBarController.selectedIndex].route(authURL)
    }
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        loadTabs()
    }

    private func loadTabs() {
        tabBarController.viewControllers = Tab.all.map { tab in
            let navigator = Navigator(delegate: self)
            navigator.rootViewController.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.imageName),
                selectedImage: nil
            )
            navigators.append(navigator)
            navigator.route(tab.url)
            return navigator.rootViewController
        }
    }
}

extension SceneController: NavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        switch proposal.viewController {
        case NumbersViewController.pathConfigurationIdentifier:
            return .acceptCustom(NumbersViewController(url: proposal.url, navigator: activeNavigator))

        default:
            return .acceptCustom(HotwireWebViewController(url: proposal.url))
        }
    }

    func handle(externalURL: URL) -> ExternalURLNavigationAction {
        /// Open SMS links in Messages.app, e.g. `sms:555-555-5555`.
        if externalURL.scheme == "sms" {
            .openViaSystem
        } else {
            .openViaSafariController
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
            activeNavigator.activeNavigationController.present(alert, animated: true)
        }
    }
}
