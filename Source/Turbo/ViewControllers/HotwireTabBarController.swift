import UIKit

/// A tab bar controller that manages multiple tabs, each associated with its own `Navigator` instance.
///
/// This controller loads tabs defined by `HotwireTab` and configures each one with its own `Navigator`.
/// The currently selected tab's navigator is exposed via the `activeNavigator` property.
///
/// By default, every tab performs its initial visit when `load(_:)` is called. Pass
/// `lazyLoadTabs: true` in the initializer to defer each tab's initial visit until the
/// first time the user selects it; the initially selected tab still loads right away.
open class HotwireTabBarController: UITabBarController, NavigationHandler {
    /// Creates a tab bar controller.
    ///
    /// - Parameters:
    ///   - navigatorDelegate: An optional delegate for each tab's `Navigator`.
    ///   - lazyLoadTabs: Controls when tab navigators perform their initial visit.
    ///     When `false` (the default), every tab starts immediately when `load(_:)`
    ///     is called. When `true`, only the initially selected tab starts when tabs
    ///     are loaded; each remaining tab starts the first time the user selects it.
    ///     This affects when each tab's content is loaded, not whether the tab's
    ///     navigator is created.
    public init(
        navigatorDelegate: NavigatorDelegate? = nil,
        lazyLoadTabs: Bool = false
    ) {
        self.navigatorDelegate = navigatorDelegate
        self.lazyLoadTabs = lazyLoadTabs
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Use init(navigatorDelegate:lazyLoadTabs:) instead.")
    }

    /// The active navigator corresponding to the currently selected tab.
    ///
    /// - Returns: A `Navigator` instance for the currently selected tab.
    /// - Note: This property will call `fatalError` if there is no tab matching the selected index.
    public var activeNavigator: Navigator {
        let selectedHotwireTab = currentHotwireTab()

        guard let navigator = navigatorsByIdentifier[selectedHotwireTab.id] else {
            fatalError("No navigator associated with tab \(selectedHotwireTab)")
        }

        return navigator
    }

    /// Loads the provided tabs and configures each one with its own navigator.
    ///
    /// - Parameters:
    ///   - tabs: An array of `HotwireTab` instances representing the tabs to be loaded.
    public func load(_ tabs: [HotwireTab]) {
        releaseRemovedNavigators()
        updateGeneration += 1
        startedTabIDs.removeAll()
        hotwireTabs = tabs
        isChangingTabs = true
        setupTabs()
        isChangingTabs = false

        if lazyLoadTabs {
            startedTabIDs.insert(currentHotwireTab().id)
            activeNavigator.start()
        } else {
            startedTabIDs.formUnion(navigatorsByIdentifier.keys)
            navigatorsByIdentifier.values.forEach { $0.start() }
        }
    }

    /// Changes the tabs while keeping each tab that stays: its navigator, its pages and
    /// whether it has started.
    ///
    /// Tabs are matched by `id`. Give each tab a stable `id` when you intend to call this
    /// method: a tab created without one gets a random `id`, so a tab that is created again
    /// is treated as new.
    ///
    /// - A tab whose `id` is already present keeps its navigator and navigation stacks.
    ///   Its title and image are updated in place. Its `url` and `isSearchTab` are fixed
    ///   when the tab is first added: changing them has no effect, so give the tab a new
    ///   `id` instead.
    /// - A tab with a new `id` gets a new navigator, which starts following the same rules
    ///   as `load(_:)`: right away, or, with `lazyLoadTabs`, when it is selected.
    /// - A tab that is left out has its navigator discarded, so `navigator(for:)` returns `nil`
    ///   for it. If its navigator is presenting its modal, the modal is dismissed, unless
    ///   something (such as a JavaScript alert) is presented on top of it. This method doesn't
    ///   dismiss other presentations, such as alerts, Safari views and your own view
    ///   controllers, though starting the newly selected tab dismisses them, as any visit
    ///   does. While something stays on screen, the discarded navigator is kept alive so it
    ///   keeps working. Adding the tab back later gives it a new navigator that starts from
    ///   its `url`.
    /// - The selected tab stays selected if it is kept. Otherwise the first tab is selected.
    /// - The selected tab's navigator is started if it has never been asked to start. A
    ///   start that the navigator delegate rejects is not retried by later updates; call
    ///   `start()` on the navigator to retry it.
    ///
    /// Unlike `load(_:)`, which recreates every navigator (for example, to start over with
    /// fresh sessions after signing in), this method only creates navigators for new tabs.
    /// Called before `load(_:)`, it behaves like `load(_:)`.
    ///
    /// - Parameters:
    ///   - tabs: An array of `HotwireTab` instances representing the tabs to show, in order.
    ///     Each tab must have a unique `id`.
    /// - Note: An empty array removes every tab. Until tabs are added again, there is no
    ///   active navigator, so `activeNavigator` and `route(_:)` will call `fatalError`.
    public func update(_ tabs: [HotwireTab]) {
        precondition(Set(tabs.map(\.id)).count == tabs.count, "Each tab must have a unique id.")

        releaseRemovedNavigators()
        updateGeneration += 1
        let generation = updateGeneration
        let previousTabID = selectedTabID()
        let previousNavigators = navigatorsByIdentifier

        hotwireTabs = tabs
        navigatorsByIdentifier.removeAll()

        let contexts = tabs.map { tab in
            if let navigator = previousNavigators[tab.id] {
                navigatorsByIdentifier[tab.id] = navigator
                return TabContext(tab: tab, navigator: navigator, viewController: navigator.rootViewController)
            }

            return tabContext(for: tab)
        }
        startedTabIDs.formIntersection(navigatorsByIdentifier.keys)

        if !lazyLoadTabs {
            // Start new tabs before they join the tab bar, so their first visit can't dismiss
            // a modal presented by another tab.
            for id in tabs.map(\.id) {
                startNavigatorIfNeeded(for: id)
                // Starting a navigator calls the navigator delegate, which may change the tabs again.
                guard generation == updateGeneration else { return }
            }
        }

        isChangingTabs = true
        if #available(iOS 18.0, *) {
            updateTabs(from: contexts, selecting: previousTabID)
        } else {
            updateViewControllers(from: contexts, selecting: previousTabID)
        }
        isChangingTabs = false

        let removedNavigators = previousNavigators.filter { navigatorsByIdentifier[$0.key] == nil }.map(\.value)
        removedNavigators.forEach { dismissModal(of: $0) }
        keepAlive(removedNavigators)

        if let selectedTabID = selectedTabID() {
            startNavigatorIfNeeded(for: selectedTabID)
        }
    }

    /// Returns the navigator associated with the given tab.
    ///
    /// - Parameter tab: The `HotwireTab` whose associated navigator to retrieve.
    /// - Returns: The existing `Navigator` instance for `tab`, or `nil` if the tab is not part of
    ///   the current configuration or the navigators have not been initialized yet (e.g., before `load(_:)`).
    public func navigator(for tab: HotwireTab) -> Navigator? {
        return navigatorsByIdentifier[tab.id]
    }

    // MARK: NavigationHandler

    open func route(_ url: URL, options: VisitOptions?, parameters: [String: Any]?) {
        activeNavigator.route(url, options: options, parameters: parameters)
    }

    open func route(_ proposal: VisitProposal) {
        activeNavigator.route(proposal)
    }

    // MARK: - Private

    private var hotwireTabs: [HotwireTab] = []
    private var navigatorsByIdentifier: [HotwireTab.ID: Navigator] = [:]
    private let navigatorDelegate: NavigatorDelegate?
    private let lazyLoadTabs: Bool
    /// The tabs whose navigators have been asked to start since they were added.
    private var startedTabIDs: Set<HotwireTab.ID> = []
    /// Incremented by `load(_:)` and `update(_:)`, so an update can tell that the tabs
    /// were changed again while it was calling out to the navigator delegate.
    private var updateGeneration = 0
    /// Navigators of removed tabs, kept alive while something they may have presented is
    /// still on screen. A web view with an unanswered JavaScript alert must outlive it.
    private var navigatorsKeptAlive: [RemovedNavigator] = []
    /// Set while `load(_:)` or `update(_:)` changes the tab bar. UIKit can report a selection
    /// made in code, and those methods start the selected navigator themselves.
    private var isChangingTabs = false

    /// Configures each tab for the appropriate platform API.
    private func setupTabs() {
        navigatorsByIdentifier.removeAll()
        let contexts = hotwireTabs.map { tabContext(for: $0) }

        if #available(iOS 18.0, *) {
            tabs = contexts.map { makeTab(from: $0) }

            if selectedTab == nil, let firstTab = tabs.first {
                selectedTab = firstTab
            }
        } else {
            viewControllers = contexts.map { makeViewController(from: $0) }

            if let viewControllers,
                !viewControllers.indices.contains(selectedIndex) {
                selectedIndex = 0
            }
        }
    }

    @available(iOS 18.0, *)
    private func updateTabs(from contexts: [TabContext], selecting selectedTabID: HotwireTab.ID?) {
        let existingTabs = Dictionary(
            tabs.map { ($0.identifier, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        tabs = contexts.map { context in
            if let tab = existingTabs[context.tab.id],
               tab.viewController === context.viewController {
                tab.title = context.tab.title
                tab.image = context.tab.image
                return tab
            }

            return makeTab(from: context)
        }

        selectedTab = tabs.first { $0.identifier == selectedTabID } ?? tabs.first
    }

    private func updateViewControllers(from contexts: [TabContext], selecting selectedTabID: HotwireTab.ID?) {
        let wasShowingMoreList = selectedViewController === moreNavigationController

        viewControllers = contexts.map { context in
            let viewController = context.viewController

            if viewControllers?.contains(viewController) == true,
               let tabBarItem = viewController.tabBarItem {
                tabBarItem.title = context.tab.title
                tabBarItem.image = context.tab.image
                tabBarItem.selectedImage = context.tab.selectedImage
                return viewController
            }

            return makeViewController(from: context)
        }

        if wasShowingMoreList, contexts.count > 5 {
            selectedViewController = moreNavigationController
        } else if let selected = contexts.first(where: { $0.tab.id == selectedTabID }) {
            selectedViewController = selected.viewController
        } else if viewControllers?.isEmpty == false {
            selectedIndex = 0
        }
    }

    private func selectedTabID() -> HotwireTab.ID? {
        if #available(iOS 18.0, *), let identifier = selectedTab?.identifier {
            return hotwireTabs.contains { $0.id == identifier } ? identifier : nil
        }

        guard let selectedViewController else { return nil }
        return navigatorsByIdentifier.first { $0.value.rootViewController === selectedViewController }?.key
    }

    /// Dismisses a removed tab's modal so it doesn't outlive its navigator. Anything presented
    /// on top of the modal, such as a JavaScript alert waiting for an answer, is left alone.
    private func dismissModal(of navigator: Navigator) {
        let modal = navigator.modalRootViewController

        func dismissIfNeeded() {
            guard modal.presentingViewController != nil, modal.presentedViewController == nil else { return }
            modal.dismiss(animated: false)
        }

        // UIKit ignores a dismissal during a presentation transition, so wait for it to end.
        if let transitionCoordinator = modal.transitionCoordinator {
            let queued = transitionCoordinator.animate(alongsideTransition: nil) { _ in dismissIfNeeded() }
            if !queued {
                DispatchQueue.main.async { dismissIfNeeded() }
            }
        } else {
            dismissIfNeeded()
        }
    }

    private func keepAlive(_ navigators: [Navigator]) {
        guard !navigators.isEmpty, let presentedViewController else { return }

        navigatorsKeptAlive += navigators.map {
            RemovedNavigator(navigator: $0, presentation: presentedViewController)
        }
    }

    private func releaseRemovedNavigators() {
        navigatorsKeptAlive.removeAll { $0.presentation?.presentingViewController == nil }
    }

    /// Starts a tab's navigator unless it has already been asked to start.
    private func startNavigatorIfNeeded(for id: HotwireTab.ID) {
        guard let navigator = navigatorsByIdentifier[id],
              !startedTabIDs.contains(id) else { return }

        startedTabIDs.insert(id)
        if navigator.rootViewController.viewControllers.isEmpty,
           navigator.modalRootViewController.viewControllers.isEmpty {
            navigator.start()
        }
    }

    private func tabContext(for tab: HotwireTab) -> TabContext {
        let navigator = makeNavigator(for: tab)

        return TabContext(
            tab: tab,
            navigator: navigator,
            viewController: navigator.rootViewController
        )
    }

    private func makeViewController(from context: TabContext) -> UIViewController {
        context.viewController.tabBarItem = context.tab.makeTabBarItem()

        return context.viewController
    }

    @available(iOS 18.0, *)
    private func makeTab(from context: TabContext) -> UITab {
        return context.tab.makeTab(context.viewController)
    }

    private func makeNavigator(for tab: HotwireTab) -> Navigator {
        let navigator = Navigator(
            configuration: .init(
                name: tab.title,
                startLocation: tab.url
            ),
            delegate: navigatorDelegate
        )

        navigatorsByIdentifier[tab.id] = navigator

        return navigator
    }

    func currentHotwireTab() -> HotwireTab {
        if #available(iOS 18.0, *),
           let identifier = selectedTab?.identifier,
           let match = hotwireTabs.first(where: { $0.id == identifier }) {
            return match
        }

        guard hotwireTabs.indices.contains(selectedIndex) else {
            fatalError("No tab matching the selected index")
        }

        return hotwireTabs[selectedIndex]
    }
}

private extension HotwireTabBarController {
    struct TabContext {
        let tab: HotwireTab
        let navigator: Navigator
        let viewController: UIViewController
    }

    struct RemovedNavigator {
        let navigator: Navigator
        weak var presentation: UIViewController?
    }
}

extension HotwireTabBarController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        startSelectedNavigator()
    }

    @available(iOS 18.0, *)
    public func tabBarController(_ tabBarController: UITabBarController, didSelectTab selectedTab: UITab, previousTab: UITab?) {
        startSelectedNavigator()
    }

    private func startSelectedNavigator() {
        guard !isChangingTabs, let id = selectedTabID() else { return }

        startedTabIDs.insert(id)
        activeNavigator.start()
    }
}
