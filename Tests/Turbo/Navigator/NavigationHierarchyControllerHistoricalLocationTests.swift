@testable import HotwireNative
import XCTest

@MainActor
final class NavigationHierarchyControllerHistoricalLocationTests: XCTestCase {
    override func setUp() {
        navigationController = TestableNavigationController()
        modalNavigationController = TestableNavigationController()

        navigator = Navigator(session: session, modalSession: modalSession)
        hierarchyController = NavigationHierarchyController(
            delegate: navigator,
            navigationController: navigationController,
            modalNavigationController: modalNavigationController
        )
        navigator.hierarchyController = hierarchyController

        loadNavigationControllerInWindow()
    }

    // Resume behaviour:
    // 1. Dismiss the modal view controller.
    // 2. Arrive back at the view controller on the "default" stack.
    func test_resumeHistoricalLocation() async throws {
        let defaultOne = VisitProposal(path: "/default_one", context: .default)
        navigator.route(defaultOne)

        let defaultTwo = VisitProposal(path: "/default_two", context: .default)
        navigator.route(defaultTwo)

        XCTAssertEqual(navigationController.viewControllers.count, 2)

        let modalOne = VisitProposal(path: "/modal_one", context: .modal)
        navigator.route(modalOne)

        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        // Reset spy's properties.
        session.visitWasCalled = false
        session.visitAction = nil

        let resumeHistoricalLocationProposal = VisitProposal(
            path: PathRule.resumeHistoricalLocation.patterns.first!,
            additionalProperties: PathRule.resumeHistoricalLocation.properties
        )
        navigator.route(resumeHistoricalLocationProposal)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigator.session.activeVisitable?.visitableURL, defaultTwo.url)
        XCTAssertFalse(session.visitWasCalled)
    }

    // Refresh behaviour:
    // 1. Dismiss the modal view controller.
    // 2. Arrive back at the view controller on the "default" stack.
    // 3. Refresh the view controller on the "default" stack by revisiting the location.
    func test_refreshHistoricalLocation() async throws {
        let defaultOne = VisitProposal(path: "/default_one", context: .default)
        navigator.route(defaultOne)

        XCTAssertEqual(navigationController.viewControllers.count, 1)

        let modalOne = VisitProposal(path: "/modal_one", context: .modal)
        navigator.route(modalOne)

        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        // Reset spy's properties.
        session.visitWasCalled = false
        session.visitAction = nil

        let refreshHistoricalLocationProposal = VisitProposal(
            path: PathRule.refreshHistoricalLocation.patterns.first!,
            additionalProperties: PathRule.refreshHistoricalLocation.properties
        )
        navigator.route(refreshHistoricalLocationProposal)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(navigator.session.activeVisitable?.visitableURL, defaultOne.url)
        XCTAssertTrue(session.visitWasCalled)
        XCTAssertEqual(session.visitAction, .restore)
    }

    // Recede behaviour:
    // 1. Dismiss the modal view controller.
    // 2. Arrive back at the view controller on the "default" stack.
    // 3. Pop the view controller on the "default" stack (unless it's already at the beginning of the backstack).
    // 4. This will trigger a refresh on the appeared view controller if the snapshot cache has been cleared by a form submission.
    @MainActor
    func test_recedeHistoricalLocation() async throws {
        let defaultOne = VisitProposal(path: "/default_one", context: .default)
        navigator.route(defaultOne)

        let defaultTwo = VisitProposal(path: "/default_two", context: .default)
        navigator.route(defaultTwo)

        XCTAssertEqual(navigationController.viewControllers.count, 2)

        let modalOne = VisitProposal(path: "/modal_one", context: .modal)
        navigator.route(modalOne)

        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let recedeHistoricalLocationProposal = VisitProposal(
            path: PathRule.recedeHistoricalLocation.patterns.first!,
            additionalProperties: PathRule.recedeHistoricalLocation.properties
        )
        navigator.route(recedeHistoricalLocationProposal)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    private let session = SessionSpy(webView: Hotwire.config.makeWebView())
    private let modalSession = Session(webView: Hotwire.config.makeWebView())

    private var navigator: Navigator!
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
}
