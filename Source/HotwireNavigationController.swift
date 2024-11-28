import UIKit

open class HotwireNavigationController: UINavigationController {
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let visitableViewController = viewController as? VisitableViewController {
            visitableViewController.appearReason = .pushedOntoNavigationStack
        }

        if let topVisitableViewController = topViewController as? VisitableViewController {
            topVisitableViewController.disappearReason = .coveredByPush
        }

        super.pushViewController(viewController, animated: animated)
    }

    open override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        if let poppedVisitableViewController = poppedViewController as? VisitableViewController {
            poppedVisitableViewController.disappearReason = .poppedFromNavigationStack
        }

        if let topVisitableViewController = topViewController as? VisitableViewController {
            topVisitableViewController.appearReason = .revealedByPop
        }

        return poppedViewController
    }

    open override func viewWillAppear(_ animated: Bool) {
        if let topVisitableViewController = topViewController as? VisitableViewController,
           topVisitableViewController.disappearReason == .tabDeselected {
            topVisitableViewController.appearReason = .tabSelected
        }
        super.viewWillAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        if tabBarController != nil,
           let topVisitableViewController = topViewController as? VisitableViewController {
            topVisitableViewController.disappearReason = .tabDeselected
        }

        super.viewWillDisappear(animated)
    }
}
