@testable import HotwireNative
import XCTest

final class HotwireTabBarControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        window = UIWindow()
        navigatorDelegate = NavigatorDelegateSpy()
    }

    override func tearDown() {
        window.rootViewController = nil
        window = nil
        navigatorDelegate = nil
        super.tearDown()
    }

    // MARK: load(_:)

    func test_load_recreatesEveryNavigator() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab])
        let oneNavigator = tabBarController.navigator(for: oneTab)
        let twoNavigator = tabBarController.navigator(for: twoTab)

        tabBarController.load([oneTab, twoTab])

        XCTAssertNotNil(tabBarController.navigator(for: oneTab))
        XCTAssertNotNil(tabBarController.navigator(for: twoTab))
        XCTAssertFalse(tabBarController.navigator(for: oneTab) === oneNavigator)
        XCTAssertFalse(tabBarController.navigator(for: twoTab) === twoNavigator)
    }

    // MARK: update(_:)

    func test_update_retainedTab_keepsNavigatorStackAndTab() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab])
        let navigator = tabBarController.navigator(for: oneTab)!
        waitForNextRunLoop()
        navigator.route(pushURL)
        let viewControllers = navigator.rootViewController.viewControllers
        XCTAssertEqual(viewControllers.count, 2)
        let tab = displayedTab(for: oneTab, in: tabBarController)

        tabBarController.update([threeTab, oneTab])

        XCTAssertTrue(tabBarController.navigator(for: oneTab) === navigator)
        XCTAssertEqual(navigator.rootViewController.viewControllers, viewControllers)
        XCTAssertTrue(displayedTab(for: oneTab, in: tabBarController) === tab)
        XCTAssertEqual(displayedViewControllers(of: tabBarController).last, navigator.rootViewController)
    }

    func test_update_addedTab_startsNavigator() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab])

        tabBarController.update([oneTab, twoTab])

        XCTAssertEqual(tabBarController.navigator(for: twoTab)?.rootViewController.viewControllers.count, 1)
        XCTAssertEqual(navigatorDelegate.proposedURLs, [oneTab.url, twoTab.url])
    }

    func test_update_addedTab_lazyLoadTabs_doesNotStartNavigator() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        tabBarController.load([oneTab])

        tabBarController.update([oneTab, twoTab])

        XCTAssertEqual(tabBarController.navigator(for: twoTab)?.rootViewController.viewControllers.count, 0)
        XCTAssertEqual(navigatorDelegate.proposedURLs, [oneTab.url])
    }

    func test_update_removedTab_hasNoNavigator() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab, threeTab])

        tabBarController.update([oneTab, twoTab])

        XCTAssertNil(tabBarController.navigator(for: threeTab))
        XCTAssertEqual(displayedViewControllers(of: tabBarController), [
            tabBarController.navigator(for: oneTab)?.rootViewController,
            tabBarController.navigator(for: twoTab)?.rootViewController
        ])
    }

    func test_update_keepsSelectedTab() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab, threeTab])
        select(twoTab, in: tabBarController)
        let navigator = tabBarController.activeNavigator

        tabBarController.update([threeTab, oneTab, twoTab])

        XCTAssertEqual(tabBarController.currentHotwireTab(), twoTab)
        XCTAssertTrue(tabBarController.activeNavigator === navigator)
        XCTAssertTrue(tabBarController.selectedViewController === navigator.rootViewController)
    }

    func test_update_selectedTabNeverStarted_lazyLoadTabs_startsItOnce() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        tabBarController.load([oneTab, twoTab])
        select(twoTab, in: tabBarController)

        tabBarController.update([oneTab, twoTab])
        tabBarController.update([twoTab, oneTab])

        XCTAssertEqual(tabBarController.navigator(for: twoTab)?.rootViewController.viewControllers.count, 1)
        XCTAssertEqual(navigatorDelegate.proposals(for: twoTab), 1)
    }

    func test_update_rejectedStart_isNotRetried() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        navigatorDelegate.rejectsProposals = true
        tabBarController.load([oneTab, twoTab])

        tabBarController.update([oneTab, twoTab])
        tabBarController.update([twoTab, oneTab])

        XCTAssertEqual(navigatorDelegate.proposedURLs, [oneTab.url])
    }

    func test_update_rejectedStart_eagerBeforeLoad_proposesOnce() {
        let tabBarController = makeTabBarController()
        navigatorDelegate.rejectsProposals = true

        tabBarController.update([oneTab])

        XCTAssertEqual(navigatorDelegate.proposedURLs, [oneTab.url])
    }

    func test_update_removedSelectedTab_lazyLoadTabs_selectsAndStartsFirstTabOnce() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        tabBarController.load([oneTab, twoTab, threeTab])
        select(threeTab, in: tabBarController)
        tabBarController.activeNavigator.start()

        tabBarController.update([twoTab, oneTab])

        XCTAssertEqual(tabBarController.currentHotwireTab(), twoTab)
        XCTAssertEqual(tabBarController.activeNavigator.rootViewController.viewControllers.count, 1)
        XCTAssertEqual(navigatorDelegate.proposals(for: twoTab), 1)
    }

    func test_update_removedAndAddedBackTab_getsNewNavigator() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab])
        let navigator = tabBarController.navigator(for: twoTab)!
        waitForNextRunLoop()
        navigator.route(pushURL)

        tabBarController.update([oneTab])
        tabBarController.update([oneTab, twoTab])

        let newNavigator = tabBarController.navigator(for: twoTab)
        XCTAssertNotNil(newNavigator)
        XCTAssertFalse(newNavigator === navigator)
        XCTAssertEqual(newNavigator?.rootViewController.viewControllers.count, 1)
    }

    func test_update_retainedTabWithChangedTitleAndImage_updatesInPlace() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab])
        let navigator = tabBarController.navigator(for: oneTab)
        let originalTab = displayedTab(for: oneTab, in: tabBarController)
        let renamedTab = HotwireTab(
            id: oneTab.id,
            title: "Renamed",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill"),
            url: oneTab.url
        )

        tabBarController.update([renamedTab, twoTab])

        XCTAssertTrue(tabBarController.navigator(for: renamedTab) === navigator)
        XCTAssertTrue(displayedTab(for: oneTab, in: tabBarController) === originalTab)
        if #available(iOS 18.0, *) {
            XCTAssertEqual(tabBarController.tabs.first?.title, "Renamed")
            XCTAssertEqual(tabBarController.tabs.first?.image, renamedTab.image)
        } else {
            XCTAssertEqual(navigator?.rootViewController.tabBarItem.title, "Renamed")
            XCTAssertEqual(navigator?.rootViewController.tabBarItem.image, renamedTab.image)
            XCTAssertEqual(navigator?.rootViewController.tabBarItem.selectedImage, renamedTab.selectedImage)
        }
    }

    func test_update_retainedTabWithChangedSearchTab_keepsTab() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab])
        let tab = displayedTab(for: twoTab, in: tabBarController)
        let searchTab = HotwireTab(id: twoTab.id, title: twoTab.title, image: nil, url: twoTab.url, isSearchTab: true)

        tabBarController.update([oneTab, searchTab])

        XCTAssertTrue(displayedTab(for: twoTab, in: tabBarController) === tab)
    }

    func test_update_retainedUnselectedTab_lazyLoadTabs_keepsTabAndStaysUnstarted() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        tabBarController.load([oneTab, twoTab])
        let tab = displayedTab(for: twoTab, in: tabBarController)

        tabBarController.update([twoTab, oneTab])

        XCTAssertTrue(displayedTab(for: twoTab, in: tabBarController) === tab)
        XCTAssertEqual(tabBarController.currentHotwireTab(), oneTab)
        XCTAssertEqual(tabBarController.navigator(for: twoTab)?.rootViewController.viewControllers.count, 0)
    }

    func test_update_retainedTabWithChangedURL_startsAtOriginalURL() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        tabBarController.load([oneTab, twoTab])
        let movedTab = HotwireTab(id: twoTab.id, title: twoTab.title, image: nil, url: URL(string: "https://example.com/moved")!)

        tabBarController.update([oneTab, movedTab])
        tabBarController.navigator(for: movedTab)?.start()

        XCTAssertEqual(navigatorDelegate.proposedURLs, [oneTab.url, twoTab.url])
    }

    func test_update_navigatorDelegateRemovesTabWhileStarting_doesNotStartRemovedTab() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab])
        navigatorDelegate.onProposal = { [weak self, weak tabBarController] proposal in
            guard let self, proposal.url == self.twoTab.url else { return }
            self.navigatorDelegate.onProposal = nil
            tabBarController?.update([self.oneTab, self.twoTab])
        }

        tabBarController.update([oneTab, twoTab, threeTab])

        XCTAssertNil(tabBarController.navigator(for: threeTab))
        XCTAssertEqual(navigatorDelegate.proposals(for: twoTab), 1)
        XCTAssertEqual(navigatorDelegate.proposals(for: threeTab), 0)
        XCTAssertEqual(displayedViewControllers(of: tabBarController).count, 2)
    }

    func test_update_navigatorDelegateUpdatesWhileSelectedTabStarts_startsItOnce() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        navigatorDelegate.onProposal = { [weak self, weak tabBarController] proposal in
            guard let self, proposal.url == self.oneTab.url else { return }
            self.navigatorDelegate.onProposal = nil
            tabBarController?.update([self.oneTab, self.twoTab])
        }

        tabBarController.update([oneTab])

        XCTAssertEqual(navigatorDelegate.proposals(for: oneTab), 1)
        XCTAssertEqual(navigatorDelegate.proposals(for: twoTab), 0)
    }

    func test_update_whileShowingMoreList_keepsMoreListSelected() throws {
        if #available(iOS 18.0, *) { throw XCTSkip("The More list is only selected this way before iOS 18.") }
        let tabs = (1...7).map {
            HotwireTab(id: "\($0)", title: "\($0)", image: nil, url: URL(string: "https://example.com/\($0)")!)
        }
        let tabBarController = makeTabBarController(lazyLoadTabs: true)
        tabBarController.load(tabs)
        tabBarController.selectedViewController = tabBarController.moreNavigationController

        tabBarController.update(tabs)

        XCTAssertTrue(tabBarController.selectedViewController === tabBarController.moreNavigationController)
    }

    func test_update_beforeLoad_behavesLikeLoad() {
        let tabBarController = makeTabBarController(lazyLoadTabs: true)

        tabBarController.update([oneTab, twoTab])

        XCTAssertEqual(tabBarController.currentHotwireTab(), oneTab)
        XCTAssertEqual(tabBarController.navigator(for: oneTab)?.rootViewController.viewControllers.count, 1)
        XCTAssertEqual(tabBarController.navigator(for: twoTab)?.rootViewController.viewControllers.count, 0)
    }

    func test_update_beforeLoad_eager_startsEveryTab() {
        let tabBarController = makeTabBarController()

        tabBarController.update([oneTab, twoTab])

        XCTAssertEqual(tabBarController.currentHotwireTab(), oneTab)
        XCTAssertEqual(navigatorDelegate.proposedURLs, [oneTab.url, twoTab.url])
    }

    func test_update_withNoTabs_removesEveryTab() {
        let tabBarController = makeTabBarController()
        tabBarController.load([oneTab, twoTab])

        tabBarController.update([])

        XCTAssertNil(tabBarController.navigator(for: oneTab))
        XCTAssertNil(tabBarController.navigator(for: twoTab))
        XCTAssertTrue(displayedViewControllers(of: tabBarController).isEmpty)
    }

    // MARK: Private

    private var window: UIWindow!
    private var navigatorDelegate: NavigatorDelegateSpy!
    private let pushURL = URL(string: "https://example.com/push")!
    private let oneTab = HotwireTab(id: "one", title: "One", image: nil, url: URL(string: "https://example.com/one")!)
    private let twoTab = HotwireTab(id: "two", title: "Two", image: nil, url: URL(string: "https://example.com/two")!)
    private let threeTab = HotwireTab(id: "three", title: "Three", image: nil, url: URL(string: "https://example.com/three")!)

    private func makeTabBarController(lazyLoadTabs: Bool = false) -> HotwireTabBarController {
        let tabBarController = HotwireTabBarController(navigatorDelegate: navigatorDelegate, lazyLoadTabs: lazyLoadTabs)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        tabBarController.loadViewIfNeeded()
        return tabBarController
    }

    /// Before iOS 18, a navigation controller drops a push made in the same run loop turn
    /// as its first push.
    private func waitForNextRunLoop() {
        let nextRunLoop = expectation(description: "Next run loop")
        DispatchQueue.main.async { nextRunLoop.fulfill() }
        wait(for: [nextRunLoop], timeout: 10)
    }

    private func select(_ tab: HotwireTab, in tabBarController: HotwireTabBarController) {
        if #available(iOS 18.0, *) {
            tabBarController.selectedTab = tabBarController.tabs.first { $0.identifier == tab.id }
        } else {
            tabBarController.selectedViewController = tabBarController.navigator(for: tab)?.rootViewController
        }
    }

    private func displayedViewControllers(of tabBarController: HotwireTabBarController) -> [UIViewController?] {
        if #available(iOS 18.0, *) {
            return tabBarController.tabs.map { $0.viewController }
        }
        return tabBarController.viewControllers ?? []
    }

    /// The `UITab` (iOS 18+) or `UITabBarItem` that shows `tab` in the tab bar.
    private func displayedTab(for tab: HotwireTab, in tabBarController: HotwireTabBarController) -> AnyObject? {
        if #available(iOS 18.0, *) {
            return tabBarController.tabs.first { $0.identifier == tab.id }
        }
        return tabBarController.navigator(for: tab)?.rootViewController.tabBarItem
    }
}

/// Accepts each visit with a plain view controller, so the tests don't load web pages.
private final class NavigatorDelegateSpy: NavigatorDelegate {
    var proposedURLs: [URL] = []
    var rejectsProposals = false
    var onProposal: ((VisitProposal) -> Void)?

    func proposals(for tab: HotwireTab) -> Int {
        proposedURLs.filter { $0 == tab.url }.count
    }

    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        proposedURLs.append(proposal.url)
        onProposal?(proposal)
        return rejectsProposals ? .reject : .acceptCustom(UIViewController())
    }
}
