import UIKit

/// The `HotwireNavigationController` is a custom subclass of `UINavigationController` designed to enhance the management of `VisitableViewController` instances within a navigation stack.
/// It tracks the reasons why a view controller appears or disappears, which is crucial for handling navigation in Hotwire-powered applications.
/// - Important: If you are using a custom or third-party navigation controller, subclass `HotwireNavigationController` to integrate its behavior.
///
/// ## Usage Notes
///
/// - **Integrating with Custom Navigation Controllers:**
///   If you're using a custom or third-party navigation controller, subclass `HotwireNavigationController` to incorporate the necessary behavior.
///
///   ```swift
///   open class YourCustomNavigationController: HotwireNavigationController {
///       // Make sure to always call super when overriding functions from `HotwireNavigationController`.
///   }
///   ```
///
/// - **Extensibility:**
///   The class is marked as `open`, allowing you to subclass and extend its functionality to suit your specific needs.
///
/// ## Limitations
///
/// - **Other Container Controllers:**
///   The current implementation focuses on `UINavigationController` and includes handling for `UITabBarController`. It does not provide out-of-the-box support for other container controllers like `UISplitViewController`.
///
/// - **Custom Navigation Setups:**
///   For completely custom navigation setups or container controllers, you will need to implement similar logic to manage the `appearReason` and `disappearReason` of `VisitableViewController` instances.
open class HotwireNavigationController: UINavigationController {
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let visitableViewController = viewController as? VisitableViewController {
            visitableViewController.appearReason = .pushedOntoNavigationStack
        }

        if let topVisitableViewController = topViewController as? VisitableViewController {
            topVisitableViewController.disappearReason = .coveredByPush
        }

        if Hotwire.config.hideTabBarWhenPushed {
            viewController.hidesBottomBarWhenPushed = (viewControllers.count >= 1)
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

    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if Hotwire.config.hideTabBarWhenPushed {
            for (index, viewController) in viewControllers.enumerated() {
                viewController.hidesBottomBarWhenPushed = (index != 0)
            }
        }

        super.setViewControllers(viewControllers, animated: animated)
    }

    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let topVisitableViewController = topViewController as? VisitableViewController {
            topVisitableViewController.appearReason = .revealedByModalDismiss
        }
        super.dismiss(animated: flag, completion: completion)
    }

    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let topVisitableViewController = topViewController as? VisitableViewController {
            topVisitableViewController.disappearReason = .coveredByModal
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
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
