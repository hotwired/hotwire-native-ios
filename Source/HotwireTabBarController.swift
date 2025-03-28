import UIKit

/// A tab bar controller that manages multiple tabs, each associated with its own `Navigator` instance.
///
/// This controller loads tabs defined by `HotwireTab` and configures each one with its own `Navigator`.
/// The currently selected tab's navigator is exposed via the `activeNavigator` property.
open class HotwireTabBarController: UITabBarController {
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
    public func load(_ tabs: [HotwireTab], navigatorDelegate: NavigatorDelegate? = nil) {
        hotwireTabs = tabs
        viewControllers = tabs.map {
            setupViewControllerForTab($0, navigatorDelegate: navigatorDelegate)
        }
    }

    // MARK: - Private

    private var hotwireTabs: [HotwireTab] = []
    private var navigatorsByTab: [HotwireTab: Navigator] = [:]

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
        let navigator = Navigator(delegate: navigatorDelegate)
        navigator.rootViewController.tabBarItem = UITabBarItem(
            title: tab.title,
            image: tab.image,
            selectedImage: nil
        )

        navigatorsByTab[tab] = navigator
        navigator.route(tab.url)

        return navigator.rootViewController
    }
}

/// Represents a tab in the `HotwireTabBarController`.
public struct HotwireTab: Hashable {
    /// The title of the tab.
    public let title: String
    /// The image used for the tab's tab bar item.
    public let image: UIImage
    /// The URL associated with the tab, used for routing.
    public let url: URL

    public init(title: String, image: UIImage, url: URL) {
        self.title = title
        self.image = image
        self.url = url
    }
}
