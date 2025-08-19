import UIKit

/// A tab bar controller that manages multiple tabs, each associated with its own `Navigator` instance.
///
/// This controller loads tabs defined by `HotwireTab` and configures each one with its own `Navigator`.
/// The currently selected tab's navigator is exposed via the `activeNavigator` property.
open class HotwireTabBarController: UITabBarController, NavigationHandler {
    public init(navigatorDelegate: NavigatorDelegate? = nil) {
        self.navigatorDelegate = navigatorDelegate
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Use init(navigatorDelegate:) instead.")
    }

    /// The active navigator corresponding to the currently selected tab.
    ///
    /// - Returns: A `Navigator` instance for the currently selected tab.
    /// - Note: This property will call `fatalError` if there is no tab matching the selected index.
    public var activeNavigator: Navigator {
        guard hotwireTabs.indices.contains(selectedIndex) else {
            fatalError("No tab matching the selected index")
        }
        let selectedTab = hotwireTabs[selectedIndex]
        return navigatorsByTab[selectedTab]!
    }

    /// Loads the provided tabs and configures each one with its own navigator.
    ///
    /// - Parameters:
    ///   - tabs: An array of `HotwireTab` instances representing the tabs to be loaded.
    ///   - navigatorDelegate: An optional instance conforming to `NavigatorDelegate`
    ///   used to handle `Navigator`'s requests and actions.
    ///
    /// This method assigns the provided tabs to the controller and sets up each tab's view controller.
    public func load(_ tabs: [HotwireTab]) {
        hotwireTabs = tabs
        viewControllers = tabs.map {
            setupViewControllerForTab($0, navigatorDelegate: navigatorDelegate)
        }
        activeNavigator.start()
        }
    }

    // MARK: NavigationHandler

    open func route(_ url: URL) {
        activeNavigator.route(url)
    }

    open func route(_ proposal: VisitProposal) {
        activeNavigator.route(proposal)
    }

    // MARK: - Private

    private var hotwireTabs: [HotwireTab] = []
    private var navigatorsByTab: [HotwireTab: Navigator] = [:]
    private let navigatorDelegate: NavigatorDelegate?

    /// Configures a navigator instance for the given tab and returns its root view controller.
    ///
    /// - Parameters:
    ///   - tab: A `HotwireTab` instance representing the tab for which to configure a navigator.
    ///   - navigatorDelegate: An optional instance conforming to `NavigatorDelegate`.
    /// - Returns: The root view controller of the configured Navigator.
    ///
    /// This method sets the tab bar item of navigator's root view controller based on the tab's title and image,
    /// stores the navigator in an internal dictionary, and routes the navigator to the tab's URL.
    private func setupViewControllerForTab(_ tab: HotwireTab,
                                           navigatorDelegate: NavigatorDelegate? = nil) -> UIViewController {
        let navigator = Navigator(
            configuration: .init(
                name: tab.title,
                startLocation: tab.url
            ),
            delegate: navigatorDelegate
        )
        
        navigator.rootViewController.tabBarItem = UITabBarItem(
            title: tab.title,
            image: tab.image,
            selectedImage: tab.selectedImage
        )

        navigatorsByTab[tab] = navigator

        return navigator.rootViewController
    }
}

extension HotwireTabBarController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard activeNavigator.rootViewController.viewControllers.isEmpty else { return }

        let tab = hotwireTabs[selectedIndex]
        activeNavigator.route(tab.url)
    }
}

/// Represents a tab in the `HotwireTabBarController`.
public struct HotwireTab: Hashable {
    /// The title of the tab.
    public let title: String
    /// The image the tab item uses.
    public let image: UIImage
    ///The image the tab item uses when the user selects it.
    ///If you don’t provide `selectedImage`, the `image` is used for both selection states.
    public let selectedImage: UIImage?
    /// The URL associated with the tab, used for routing.
    public let url: URL

    public init(title: String,
                image: UIImage,
                selectedImage: UIImage? = nil,
                url: URL) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.url = url
    }
}
