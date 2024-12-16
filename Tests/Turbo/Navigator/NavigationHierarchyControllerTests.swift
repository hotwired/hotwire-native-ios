@testable import HotwireNative
import SafariServices
import XCTest

/// Tests are written in the following format:
/// `test_currentContext_givenContext_givenPresentation_modifiers_result()`
/// See the README for a more visually pleasing table.
final class NavigationHierarchyControllerTests: XCTestCase {
    override func setUp() {
        navigationController = TestableNavigationController()
        modalNavigationController = TestableNavigationController()

        navigator = Navigator(session: session, modalSession: modalSession)
        hierarchyController = NavigationHierarchyController(delegate: navigator, navigationController: navigationController, modalNavigationController: modalNavigationController)
        navigator.hierarchyController = hierarchyController

        loadNavigationControllerInWindow()
    }

    func test_default_default_default_defaultOptionsParamater_pushesOnMainStack() {
        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)

        navigator.route(twoURL)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)
        assertVisited(url: twoURL, on: .main)
    }

    func test_default_default_default_nilOptionsParameter_pushesOnMainStack() {
        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)

        navigator.route(twoURL, options: nil)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)
        assertVisited(url: twoURL, on: .main)
    }

    func test_default_default_default_visitingSamePage_replacesOnMainStack() {
        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(oneURL)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 1)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)
        assertVisited(url: oneURL, on: .main)
    }

    func test_default_default_default_visitingPreviousPage_popsAndVisitsOnMainStack() {
        navigator.route(oneURL)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 1)

        navigator.route(twoURL)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 2)

        navigator.route(oneURL)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 1)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)
        assertVisited(url: oneURL, on: .main)
    }

    func test_default_default_default_replaceAction_replacesOnMainStack() {
        let proposal = VisitProposal(action: .replace)
        navigator.route(proposal)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .main)
    }

    func test_default_default_replace_replacesOnMainStack() {
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        let proposal = VisitProposal(presentation: .replace)
        navigator.route(proposal)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .main)
    }
    
    func test_default_default_refresh_refreshesPreviousController() {
        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        
        navigator.route(twoURL)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 2)
        
        /// Refreshing should pop the view controller and refresh the underlying controller.
        let proposal = VisitProposal(presentation: .refresh)
        navigator.route(proposal)
        
        let visitable = navigator.session.activeVisitable as! VisitableViewController
        XCTAssertEqual(visitable.visitableURL, oneURL)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 1)
    }
    
    func test_default_modal_refresh_refreshesPreviousController() {
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        
        let oneURLProposal = VisitProposal(path: "/one", context: .modal)
        navigator.route(oneURLProposal)
        
        let twoURLProposal = VisitProposal(path: "/two", context: .modal)
        navigator.route(twoURLProposal)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 2)
        
        /// Refreshing should pop the view controller and refresh the underlying controller.
        let proposal = VisitProposal(presentation: .refresh)
        navigator.route(proposal)
        
        let visitable = navigator.modalSession.activeVisitable as! VisitableViewController
        XCTAssertEqual(visitable.visitableURL, oneURL)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
    }
    
    func test_default_modal_refresh_dismissesAndRefreshesMainStackTopViewController() {
        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        
        let twoURLProposal = VisitProposal(path: "/two", context: .modal)
        navigator.route(twoURLProposal)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
        
        /// Refreshing should dismiss the view controller and refresh the underlying controller.
        let proposal = VisitProposal(context: .modal, presentation: .refresh)
        navigator.route(proposal)
        
        let visitable = navigator.session.activeVisitable as! VisitableViewController
        XCTAssertEqual(visitable.visitableURL, oneURL)
        
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigator.rootViewController.viewControllers.count, 1)
    }

    func test_default_modal_default_presentsModal() {
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        let proposal = VisitProposal(context: .modal)
        navigator.route(proposal)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
        XCTAssertIdentical(navigationController.presentedViewController, modalNavigationController)
        XCTAssert(modalNavigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .modal)
    }

    func test_default_modal_replace_presentsModal() {
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        let proposal = VisitProposal(context: .modal, presentation: .replace)
        navigator.route(proposal)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
        XCTAssertIdentical(navigationController.presentedViewController, modalNavigationController)
        XCTAssert(modalNavigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .modal)
    }

    func test_modal_default_default_dismissesModalThenPushesOnMainStack() {
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(VisitProposal(context: .modal))
        XCTAssertIdentical(navigationController.presentedViewController, modalNavigationController)

        let proposal = VisitProposal()
        navigator.route(proposal)
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssert(navigationController.viewControllers.last is VisitableViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        assertVisited(url: proposal.url, on: .main)
    }

    func test_modal_default_replace_dismissesModalThenReplacedOnMainStack() {
        navigator.route(VisitProposal(context: .modal))
        XCTAssertIdentical(navigationController.presentedViewController, modalNavigationController)

        let proposal = VisitProposal(presentation: .replace)
        navigator.route(proposal)
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(modalNavigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .main)
    }

    func test_modal_modal_default_pushesOnModalStack() {
        navigator.route(VisitProposal(path: "/one", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(path: "/two", context: .modal)
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 2)
        XCTAssert(modalNavigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .modal)
    }

    func test_modal_modal_default_replaceAction_pushesOnModalStack() {
        navigator.route(VisitProposal(path: "/one", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(path: "/two", action: .replace, context: .modal)
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
        XCTAssert(modalNavigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .modal)
    }

    func test_modal_modal_replace_pushesOnModalStack() {
        navigator.route(VisitProposal(path: "/one", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(path: "/two", context: .modal, presentation: .replace)
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
        XCTAssert(modalNavigationController.viewControllers.last is VisitableViewController)
        assertVisited(url: proposal.url, on: .modal)
    }

    func test_default_any_pop_popsOffMainStack() {
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(VisitProposal())
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        navigator.route(VisitProposal(presentation: .pop))
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    func test_modal_any_pop_popsOffModalStack() {
        navigator.route(VisitProposal(path: "/one", context: .modal))
        navigator.route(VisitProposal(path: "/two", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 2)

        navigator.route(VisitProposal(presentation: .pop))
        XCTAssertNotNil(navigationController.presentedViewController)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
    }

    func test_modal_any_pop_exactlyOneModal_dismissesModal() {
        navigator.route(VisitProposal(path: "/one", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        navigator.route(VisitProposal(presentation: .pop))
        XCTAssertNil(navigationController.presentedViewController)
    }

    func test_any_any_clearAll_dismissesModalThenPopsToRootOnMainStack() {
        let rootController = UIViewController()
        navigationController.viewControllers = [rootController, UIViewController(), UIViewController()]
        XCTAssertEqual(navigationController.viewControllers.count, 3)

        let proposal = VisitProposal(presentation: .clearAll)
        navigator.route(proposal)
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers, [rootController])
    }

    func test_any_any_replaceRoot_dismissesModalThenReplacesRootOnMainStack() {
        let rootController = UIViewController()
        navigationController.viewControllers = [rootController, UIViewController(), UIViewController()]
        XCTAssertEqual(navigationController.viewControllers.count, 3)

        navigator.route(VisitProposal(presentation: .replaceRoot))
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.viewControllers.last is VisitableViewController)
    }

    func test_presentingUIAlertController_doesNotWrapInNavigationController() {
        navigator.delegate = alertControllerDelegate

        navigator.route(VisitProposal(path: "/alert"))

        XCTAssert(navigationController.presentedViewController is UIAlertController)
    }

    func test_presentingUIAlertController_onTheModal_doesNotWrapInNavigationController() {
        navigator.delegate = alertControllerDelegate

        navigator.route(VisitProposal(context: .modal))
        navigator.route(VisitProposal(path: "/alert"))

        XCTAssert(modalNavigationController.presentedViewController is UIAlertController)
    }

    func test_none_cancelsNavigation() {
        let topViewController = UIViewController()
        navigationController.pushViewController(topViewController, animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        let proposal = VisitProposal(path: "/cancel", presentation: .none)
        navigator.route(proposal)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.topViewController == topViewController)
        XCTAssertNotEqual(navigator.session.activeVisitable?.visitableURL, proposal.url)
    }

    func test_externalURL_presentsSafariViewController() throws {
        let externalURL = URL(string: "https://example.com")!
        navigator.session(navigator.session, openExternalURL: externalURL)

        XCTAssert(navigationController.presentedViewController is SFSafariViewController)
        XCTAssertEqual(navigationController.presentedViewController?.modalPresentationStyle, .pageSheet)
    }

    func test_invalidExternalURL_doesNotPresentSafariViewController() throws {
        let externalURL = URL(string: "ftp://example.com")!
        navigator.session(navigator.session, openExternalURL: externalURL)

        /// No assertions needed. App will crash if we pass a non-http or non-https scheme to SFSafariViewController.
    }

    // MARK: Private

    private enum Context {
        case main, modal
    }

    private let baseURL = URL(string: "https://example.com")!
    private lazy var oneURL = baseURL.appendingPathComponent("/one")
    private lazy var twoURL = baseURL.appendingPathComponent("/two")

    private let session = Session(webView: Hotwire.config.makeWebView())
    private let modalSession = Session(webView: Hotwire.config.makeWebView())

    private var navigator: Navigator!
    private let alertControllerDelegate = AlertControllerDelegate()
    private var hierarchyController: NavigationHierarchyController!
    private var navigationController: TestableNavigationController!
    private var modalNavigationController: TestableNavigationController!

    private let window = UIWindow()

    // Simulate a "real" app so presenting view controllers works under test.
    private func loadNavigationControllerInWindow() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.loadViewIfNeeded()
    }

    private func assertVisited(url: URL, on context: Context) {
        switch context {
        case .main:
            XCTAssertEqual(navigator.session.activeVisitable?.visitableURL, url)
        case .modal:
            XCTAssertEqual(navigator.modalSession.activeVisitable?.visitableURL, url)
        }
    }
}

// MARK: - EmptyNavigationDelegate

private class EmptyNavigationDelegate: NavigationHierarchyControllerDelegate {
    func visit(_: Visitable, on: NavigationHierarchyController.NavigationStackType, with: VisitOptions) {}
    func refreshVisitable(navigationStack: NavigationHierarchyController.NavigationStackType, newTopmostVisitable: any Visitable) { }
}

// MARK: - VisitProposal extension

private extension VisitProposal {
    init(path: String = "", action: VisitAction = .advance, context: Navigation.Context = .default, presentation: Navigation.Presentation = .default) {
        let url = URL(string: "https://example.com")!.appendingPathComponent(path)
        let options = VisitOptions(action: action, response: nil)
        let properties: PathProperties = [
            "context": context.rawValue,
            "presentation": presentation.rawValue
        ]
        self.init(url: url, options: options, properties: properties)
    }
}

// MARK: - AlertControllerDelegate

private class AlertControllerDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        if proposal.url.path == "/alert" {
            return .acceptCustom(UIAlertController(title: "Alert", message: nil, preferredStyle: .alert))
        }

        return .accept
    }
}
