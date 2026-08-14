import HotwireNative
import SwiftUI

final class AppNavigatorDelegate: NavigatorDelegate, HotwireTabBarControllerDelegate {
    weak var tabBarController: HotwireTabBarController?

    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        switch proposal.viewController {
        case NumbersView.pathConfigurationIdentifier:
            return .accept(NumbersView(url: proposal.url, navigator: navigator))

        default:
            return .accept
        }
    }

    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retryHandler: RetryBlock?) {
        if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
            promptForAuthentication()
        } else if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error, retryHandler: retryHandler)
        } else {
            showErrorAlert(error: error)
        }
    }

    // MARK: - Private

    private func promptForAuthentication() {
        guard let tabBarController else { return }

        // Clean up empty screen from 401 response.
        tabBarController.activeNavigator.pop(animated: false)

        let authURL = Demo.current.appendingPathComponent("/session/new")
        tabBarController.activeNavigator.route(authURL)
    }

    private func showErrorAlert(error: Error) {
        guard let tabBarController else { return }

        let alert = UIAlertController(
            title: "Visit failed!",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        tabBarController.activeNavigator.rootViewController.present(alert, animated: true)
    }
}
