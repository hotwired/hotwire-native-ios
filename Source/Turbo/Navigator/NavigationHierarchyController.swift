import SafariServices
import UIKit
import WebKit

class NavigationHierarchyController {
    let navigationController: UINavigationController
    let modalNavigationController: UINavigationController

    var rootViewController: UIViewController { navigationController }
    var activeNavigationController: UINavigationController {
        navigationController.presentedViewController != nil ? modalNavigationController : navigationController
    }

    enum NavigationStackType {
        case main
        case modal
    }

    func navController(for navigationType: NavigationStackType) -> UINavigationController {
        switch navigationType {
        case .main: navigationController
        case .modal: modalNavigationController
        }
    }

    init(
        delegate: NavigationHierarchyControllerDelegate,
        navigationController: UINavigationController = Hotwire.config.defaultNavigationController(),
        modalNavigationController: UINavigationController = Hotwire.config.defaultNavigationController()
    ) {
        self.delegate = delegate
        self.navigationController = navigationController
        self.modalNavigationController = modalNavigationController
    }

    func route(controller: UIViewController, proposal: VisitProposal) {
        if let alert = controller as? UIAlertController {
            presentAlert(alert, via: proposal)
        } else {
            if let visitable = controller as? Visitable {
                visitable.visitableView.allowsPullToRefresh = proposal.pullToRefreshEnabled
            }

            switch proposal.presentation {
            case .default:
                navigate(with: controller, via: proposal)
            case .pop:
                pop(animated: proposal.animated)
            case .replace:
                replace(with: controller, via: proposal)
            case .refresh:
                refresh(via: proposal)
            case .clearAll:
                clearAll(animated: proposal.animated)
            case .replaceRoot:
                replaceRoot(with: controller, via: proposal)
            case .none:
                break // Do nothing.
            }
        }
    }

    func pop(animated: Bool) {
        if navigationController.presentedViewController != nil {
            if modalNavigationController.viewControllers.count == 1 {
                navigationController.dismiss(animated: animated)
            } else {
                modalNavigationController.popViewController(animated: animated)
            }
        } else {
            navigationController.popViewController(animated: animated)
        }
    }

    func clearAll(animated: Bool) {
        navigationController.dismiss(animated: animated)
        navigationController.popToRootViewController(animated: animated)
        refreshIfTopViewControllerIsVisitable(from: .main)
    }

    // MARK: Private

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private unowned let delegate: NavigationHierarchyControllerDelegate

    private func presentAlert(_ alert: UIAlertController, via proposal: VisitProposal) {
        if navigationController.presentedViewController != nil {
            modalNavigationController.present(alert, animated: proposal.animated)
        } else {
            navigationController.present(alert, animated: proposal.animated)
        }
    }

    private func navigate(with controller: UIViewController, via proposal: VisitProposal) {
        switch proposal.context {
        case .default:
            if let visitable = controller as? Visitable {
                delegate.visit(visitable, on: .main, with: proposal.options)
            }
            navigationController.dismiss(animated: proposal.animated)
            pushOrReplace(on: navigationController, with: controller, via: proposal)
        case .modal:
            if let visitable = controller as? Visitable {
                delegate.visit(visitable, on: .modal, with: proposal.options)
            }
            if navigationController.presentedViewController != nil, !modalNavigationController.isBeingDismissed {
                pushOrReplace(on: modalNavigationController, with: controller, via: proposal)
            } else {
                modalNavigationController.setViewControllers([controller], animated: proposal.animated)
                modalNavigationController.setModalPresentationStyle(via: proposal)
                navigationController.present(modalNavigationController, animated: proposal.animated)
            }
        }
    }

    private func pushOrReplace(on navigationController: UINavigationController, with controller: UIViewController, via proposal: VisitProposal) {
        if visitingSamePage(on: navigationController, with: controller, via: proposal.url) {
            navigationController.replaceLastViewController(with: controller)
        } else if visitingPreviousPage(on: navigationController, with: controller, via: proposal.url) {
            navigationController.popViewController(animated: proposal.animated)
        } else if proposal.options.action == .advance {
            navigationController.pushViewController(controller, animated: proposal.animated)
        } else {
            navigationController.replaceLastViewController(with: controller)
        }
    }

    private func visitingSamePage(on navigationController: UINavigationController, with controller: UIViewController, via url: URL) -> Bool {
        if let visitable = navigationController.topViewController as? Visitable {
            return visitable.visitableURL == url
        } else if let topViewController = navigationController.topViewController {
            return topViewController.isMember(of: type(of: controller))
        }
        return false
    }

    private func visitingPreviousPage(on navigationController: UINavigationController, with controller: UIViewController, via url: URL) -> Bool {
        guard navigationController.viewControllers.count >= 2 else { return false }

        let previousController = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        if let previousVisitable = previousController as? VisitableViewController {
            return previousVisitable.visitableURL == url
        }
        return type(of: previousController) == type(of: controller)
    }

    private func replace(with controller: UIViewController, via proposal: VisitProposal) {
        switch proposal.context {
        case .default:
            if let visitable = controller as? Visitable {
                delegate.visit(visitable, on: .main, with: proposal.options)
            }
            navigationController.dismiss(animated: proposal.animated)
            navigationController.replaceLastViewController(with: controller)
        case .modal:
            if let visitable = controller as? Visitable {
                delegate.visit(visitable, on: .modal, with: proposal.options)
            }
            if navigationController.presentedViewController != nil {
                modalNavigationController.replaceLastViewController(with: controller)
            } else {
                modalNavigationController.setViewControllers([controller], animated: false)
                modalNavigationController.setModalPresentationStyle(via: proposal)
                navigationController.present(modalNavigationController, animated: proposal.animated)
            }
        }
    }

    private func refresh(via proposal: VisitProposal) {
        if navigationController.presentedViewController != nil {
            if modalNavigationController.viewControllers.count == 1 {
                navigationController.dismiss(animated: proposal.animated)
                refreshIfTopViewControllerIsVisitable(from: .main)
            } else {
                modalNavigationController.popViewController(animated: proposal.animated)
                refreshIfTopViewControllerIsVisitable(from: .modal)
            }
        } else {
            navigationController.popViewController(animated: proposal.animated)
            refreshIfTopViewControllerIsVisitable(from: .main)
        }
    }

    private func replaceRoot(with controller: UIViewController, via proposal: VisitProposal) {
        if let visitable = controller as? Visitable {
            delegate.visit(visitable, on: .main, with: .init(action: .replace))
        }

        navigationController.dismiss(animated: proposal.animated)
        navigationController.setViewControllers([controller], animated: proposal.animated)
    }
    
    private func refreshIfTopViewControllerIsVisitable(from stack: NavigationStackType) {
        if let navControllerTopmostVisitable = navController(for: stack).topViewController as? Visitable {
            delegate.refreshVisitable(navigationStack: stack,
                                                  newTopmostVisitable: navControllerTopmostVisitable)
        }
    }
}
