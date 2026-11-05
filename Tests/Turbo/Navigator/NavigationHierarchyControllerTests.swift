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

        navigator = Navigator(
            session: session,
            modalSession: modalSession,
            configuration: .init(name: "Test", startLocation: oneURL)
        )
        hierarchyController = NavigationHierarchyController(delegate: navigator, navigationController: navigationController, modalNavigationController: modalNavigationController)
        navigator.hierarchyController = hierarchyController

        loadNavigationControllerInWindow()
    }

    func test_start_succeeds_when_no_view_controllers_on_stack() {
        navigator.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)
        assertVisited(url: oneURL, on: .main)
    }

    func test_start_fails_when_view_controllers_on_stack() {
        navigator.route(twoURL)
        navigator.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigator.rootViewController.viewControllers.last is VisitableViewController)
        assertVisited(url: twoURL, on: .main)
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

    func test_customViewController_visitingDifferentURL_pushesOnMainStack() {
        let navigator = makeCustomViewControllerNavigator()

        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.topViewController is CustomViewController)

        navigator.route(twoURL)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssert(navigationController.topViewController is CustomViewController)
    }

    func test_customViewController_visitingSameURL_replacesOnMainStack() {
        let navigator = makeCustomViewControllerNavigator()

        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.topViewController is CustomViewController)
    }

    func test_customViewController_visitingPreviousURL_popsOnMainStack() {
        let navigator = makeCustomViewControllerNavigator()

        navigator.route(oneURL)
        navigator.route(twoURL)
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        navigator.route(oneURL)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.topViewController is CustomViewController)
    }

    func test_unroutedViewController_onStack_visitPushesOnMainStack() {
        // A view controller pushed onto the stack outside the navigator (e.g. mixed native
        // navigation) has no routed location. A subsequent visit must treat it as a new page
        // and push — never crash or incorrectly replace/pop.
        navigationController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(oneURL)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssert(navigationController.topViewController is VisitableViewController)
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
        XCTAssertEqual(visitable.initialVisitableURL, oneURL)
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
        XCTAssertEqual(visitable.initialVisitableURL, oneURL)
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
        XCTAssertEqual(visitable.initialVisitableURL, oneURL)
        
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
    
    func test_modal_default_default_replaceAction_pushesOnMainStack_ifDifferentDestination() {
        navigator.route(VisitProposal(path: "/one", context: .default))
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        
        navigator.route(VisitProposal(path: "/two", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(path: "/three", action: .replace, context: .default)
        navigator.route(proposal)
        
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        assertVisited(url: proposal.url, on: .main)
    }
    
    func test_modal_default_default_replaceAction_replacesOnMainStack_ifSameDestination() {
        navigator.route(VisitProposal(path: "/one", context: .default))
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        
        navigator.route(VisitProposal(path: "/two", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(path: "/one", action: .replace, context: .default)
        navigator.route(proposal)
        
        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        assertVisited(url: proposal.url, on: .main)
    }

    /// Verifies that when navigating back to the same path with a different query string,
    /// and `query_string_presentation` is set to "default", the route is treated as a different location.
    /// This results in a new view controller being pushed onto the main navigation stack,
    /// rather than replacing the existing one.
    func test_modal_default_default_replaceAction_pushesOnMainStack_withDefaultQueryStringPresentation() {
        navigator.route(VisitProposal(path: "/one", context: .default))
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(VisitProposal(path: "/two", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(
            path: "/one",
            queryItems: [URLQueryItem(name: "foo", value: "bar")],
            action: .replace,
            context: .default,
            additionalProperties: ["query_string_presentation": "default"]
        )
        navigator.route(proposal)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        assertVisited(url: proposal.url, on: .main)
    }

    /// Verifies that when navigating back to the same path with a different query string,
    /// and `query_string_presentation` is set to "replace", the route is treated as the same location.
    /// This results in replacing the existing view controller with a new one.
    func test_modal_default_default_replaceAction_replacesOnMainStack_withReplaceQueryStringPresentation() {
        navigator.route(VisitProposal(path: "/one", context: .default))
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        navigator.route(VisitProposal(path: "/two", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)

        let proposal = VisitProposal(
            path: "/one",
            queryItems: [URLQueryItem(name: "foo", value: "bar")],
            action: .replace,
            context: .default,
            additionalProperties: ["query_string_presentation": "replace"]
        )
        navigator.route(proposal)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        assertVisited(url: proposal.url, on: .main)
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
        XCTAssertNotEqual(navigator.session.activeVisitable?.initialVisitableURL, proposal.url)
    }

    func test_modalStyle_isCorrectlySet() throws {
        let proposal = VisitProposal(
            path: "/new",
            context: .modal,
            additionalProperties: [
                "modal_style": "form_sheet"
            ])
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.modalPresentationStyle, .formSheet)
    }

    func test_noModalStyle_defaultsToAutomatic() throws {
        let proposal = VisitProposal(
            path: "/new",
            context: .modal
        )
        navigator.route(proposal)
        // For most view controllers, UIKit maps [automatic] to:
        // UIModalPresentationStyle.formSheet in iOS 18 and later
        // UIModalPresentationStyle.pageSheet in versions of iOS earlier than iOS 18
        // Some system view controllers may map it to a different style.
        // https://developer.apple.com/documentation/uikit/uimodalpresentationstyle/automatic
        if #available(iOS 18, *) {
            XCTAssertEqual(modalNavigationController.modalPresentationStyle, .formSheet)
        } else {
            XCTAssertEqual(modalNavigationController.modalPresentationStyle, .pageSheet)
        }
    }

    func test_modalDismissGestureEnabled_isCorrectlySet() throws {
        let proposal = VisitProposal(
            path: "/new",
            context: .modal,
            additionalProperties: [
                "modal_dismiss_gesture_enabled": true
            ])
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.visibleViewController?.isModalInPresentation, false)
    }

    func test_modalDismissGestureDisabled_isCorrectlySet() throws {
        let proposal = VisitProposal(
            path: "/new",
            context: .modal,
            additionalProperties: [
                "modal_dismiss_gesture_enabled": false
            ])
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.visibleViewController?.isModalInPresentation, true)
    }

    func test_modalDismissGestureEnabled_missing_defaultsToTrue() throws {
        let proposal = VisitProposal(
            path: "/new",
            context: .modal
        )
        navigator.route(proposal)
        XCTAssertEqual(modalNavigationController.visibleViewController?.isModalInPresentation, false)
    }

    // MARK: Redirects

    /// A followed redirect within the default context is re-proposed by Turbo with
    /// a `replace` action, so it replaces the pre-redirect controller in place and
    /// must not pop the screen beneath it.
    func test_redirect_mainToMain_replacesRedirectedControllerAndKeepsUnderlyingScreen() {
        navigator.route(oneURL)
        navigator.route(twoURL)
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        // /two responded with a redirect to /three, re-proposed by the main session.
        let redirect = VisitProposal(path: "/three", action: .replace, context: .default, redirected: true)
        navigator.session(session, didProposeVisit: redirect)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        let underlying = navigationController.viewControllers.first as? VisitableViewController
        XCTAssertEqual(underlying?.initialVisitableURL, oneURL)
        assertVisited(url: redirect.url, on: .main)
    }

    /// A redirect that crosses from the default context to a modal is re-proposed by
    /// the main session (which performed the request). The stranded main controller
    /// must be popped so it isn't left orphaned beneath the modal.
    func test_redirect_mainToModal_popsOrphanedMainControllerAndPresentsModal() {
        navigator.route(oneURL)
        navigator.route(twoURL)
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        let redirect = VisitProposal(path: "/modal", action: .replace, context: .modal, redirected: true)
        navigator.session(session, didProposeVisit: redirect)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(modalNavigationController.viewControllers.count, 1)
        XCTAssertIdentical(navigationController.presentedViewController, modalNavigationController)
        assertVisited(url: redirect.url, on: .modal)
    }

    /// A followed redirect within the modal context replaces the pre-redirect
    /// controller on the modal stack and must not pop the modal screen beneath it.
    func test_redirect_modalToModal_replacesRedirectedControllerAndKeepsUnderlyingModalScreen() {
        navigator.route(VisitProposal(path: "/one", context: .modal))
        navigator.route(VisitProposal(path: "/two", context: .modal))
        XCTAssertEqual(modalNavigationController.viewControllers.count, 2)

        let redirect = VisitProposal(path: "/three", action: .replace, context: .modal, redirected: true)
        navigator.session(modalSession, didProposeVisit: redirect)

        XCTAssertEqual(modalNavigationController.viewControllers.count, 2)
        let underlying = modalNavigationController.viewControllers.first as? VisitableViewController
        XCTAssertEqual(underlying?.initialVisitableURL, oneURL)
        assertVisited(url: redirect.url, on: .modal)
    }

    /// A redirect that crosses from the modal context to the default context is
    /// re-proposed by the modal session. The modal is dismissed and the redirected
    /// destination is routed onto the main stack.
    func test_redirect_modalToMain_dismissesModalAndRoutesOntoMainStack() {
        navigator.route(oneURL)
        navigator.route(VisitProposal(path: "/modal", context: .modal))
        XCTAssertIdentical(navigationController.presentedViewController, modalNavigationController)

        let redirect = VisitProposal(path: "/three", action: .replace, context: .default, redirected: true)
        navigator.session(modalSession, didProposeVisit: redirect)

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        assertVisited(url: redirect.url, on: .main)
        XCTAssertNil(navigationController.presentedViewController)
    }

    func test_redirect_modalToMain_advance_fromModalMarkedAsReplacingPresentingPage_replacesPageBeneathModal() {
        modalSession.pathConfiguration = replacingPresentingPageConfiguration
        navigator.route(oneURL)
        navigator.route(twoURL)
        navigator.route(VisitProposal(path: "/two/moves/new", context: .modal))

        let redirect = VisitProposal(path: "/three", action: .advance, context: .default, redirected: true)
        navigator.session(modalSession, didProposeVisit: redirect)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.compactMap { ($0 as? Visitable)?.initialVisitableURL }, [oneURL, redirect.url])
        assertVisited(url: redirect.url, on: .main)
    }

    func test_redirect_modalToMain_advance_fromModalNotMarkedAsReplacingPresentingPage_pushesOnTopOfPageBeneathModal() {
        modalSession.pathConfiguration = replacingPresentingPageConfiguration
        navigator.route(oneURL)
        navigator.route(twoURL)
        navigator.route(VisitProposal(path: "/two/copies/new", context: .modal))

        let redirect = VisitProposal(path: "/three", action: .advance, context: .default, redirected: true)
        navigator.session(modalSession, didProposeVisit: redirect)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.compactMap { ($0 as? Visitable)?.initialVisitableURL }, [oneURL, twoURL, redirect.url])
    }

    func test_redirect_modalToMain_advance_fromModalMarkedAsReplacingPresentingPage_toPageBeforeThePresentingPage_popsBackToIt() {
        modalSession.pathConfiguration = replacingPresentingPageConfiguration
        navigator.route(oneURL)
        navigator.route(twoURL)
        navigator.route(VisitProposal(path: "/two/moves/new", context: .modal))

        let redirect = VisitProposal(path: "/one", action: .advance, context: .default, redirected: true)
        navigator.session(modalSession, didProposeVisit: redirect)

        XCTAssertNil(navigationController.presentedViewController)
        XCTAssertEqual(navigationController.viewControllers.compactMap { ($0 as? Visitable)?.initialVisitableURL }, [oneURL])
    }

    func test_redirect_modalToMain_advance_fromModalMarkedAsReplacingPresentingPage_keepsProposalResponse() {
        modalSession.pathConfiguration = replacingPresentingPageConfiguration
        navigator.route(oneURL)
        navigator.route(VisitProposal(path: "/one/moves/new", context: .modal))

        let redirect = VisitProposal(path: "/three", action: .advance, context: .default, redirected: true)
        navigator.session(modalSession, didProposeVisit: redirect)

        XCTAssertEqual(navigator.session.activeVisitable?.initialVisitableURL, redirect.url)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    func test_redirect_modalToMain_singleControllerModal_routesAfterModalDismissalCompletes() {
        assertModalToMainRedirectWaitsForDismissal(
            modalProposals: [VisitProposal(path: "/modal-one", context: .modal)]
        )
    }

    func test_redirect_modalToMain_multipleControllerModal_routesAfterModalDismissalCompletes() {
        assertModalToMainRedirectWaitsForDismissal(
            modalProposals: [
                VisitProposal(path: "/modal-one", context: .modal),
                VisitProposal(path: "/modal-two", context: .modal)
            ]
        )
    }

    // MARK: Private

    private func assertModalToMainRedirectWaitsForDismissal(modalProposals: [VisitProposal]) {
        let delayedNavigationController = DelayedDismissalNavigationController()
        let testModalNavigationController = TestableNavigationController()
        let redirectDelegate = RedirectProposalRecordingDelegate()
        let testSession = Session(webView: Hotwire.config.makeWebView())
        let testModalSession = Session(webView: Hotwire.config.makeWebView())
        let testNavigator = Navigator(
            session: testSession,
            modalSession: testModalSession,
            delegate: redirectDelegate,
            configuration: .init(name: "Test", startLocation: oneURL)
        )
        testNavigator.hierarchyController = NavigationHierarchyController(
            delegate: testNavigator,
            navigationController: delayedNavigationController,
            modalNavigationController: testModalNavigationController
        )
        loadNavigationControllerInWindow(delayedNavigationController)

        testNavigator.route(oneURL)
        for proposal in modalProposals {
            testNavigator.route(proposal)
        }

        let redirect = VisitProposal(path: "/three", action: .replace, context: .default, redirected: true)
        testNavigator.session(testModalSession, didProposeVisit: redirect)

        XCTAssertTrue(redirectDelegate.redirectProposals.isEmpty)
        XCTAssertIdentical(delayedNavigationController.presentedViewController, testModalNavigationController)

        delayedNavigationController.completeDismissal()

        XCTAssertEqual(redirectDelegate.redirectProposals.count, 1)
        let receivedProposal = redirectDelegate.redirectProposals[0]
        XCTAssertEqual(receivedProposal.url, redirect.url)
        XCTAssertEqual(receivedProposal.options.action, redirect.options.action)
        XCTAssertEqual(receivedProposal.context, redirect.context)
        XCTAssertEqual(receivedProposal.isRedirect, redirect.isRedirect)
        XCTAssertNil(delayedNavigationController.presentedViewController)
        XCTAssertEqual(testNavigator.session.activeVisitable?.initialVisitableURL, redirect.url)
    }

    private enum Context {
        case main, modal
    }

    private var replacingPresentingPageConfiguration: PathConfiguration {
        let json = """
        {"rules": [{"patterns": ["/moves/new"], "properties": {"context": "modal", "replaces_presenting_page_on_redirect": true}},
                   {"patterns": ["/copies/new"], "properties": {"context": "modal"}}]}
        """
        return PathConfiguration(sources: [.data(Data(json.utf8))])
    }

    private let baseURL = URL(string: "https://example.com")!
    private lazy var oneURL = baseURL.appendingPathComponent("/one")
    private lazy var twoURL = baseURL.appendingPathComponent("/two")

    private let session = Session(webView: Hotwire.config.makeWebView())
    private let modalSession = Session(webView: Hotwire.config.makeWebView())

    private var navigator: Navigator!
    private let alertControllerDelegate = AlertControllerDelegate()
    // `Navigator.delegate` is weak, so the test must hold a strong reference.
    private let customViewControllerDelegate = CustomViewControllerDelegate()
    private var hierarchyController: NavigationHierarchyController!
    private var navigationController: TestableNavigationController!
    private var modalNavigationController: TestableNavigationController!

    private let window = UIWindow()

    // A navigator whose delegate routes custom, non-`Visitable` view controllers, wired to the
    // same navigation controllers the test asserts against.
    private func makeCustomViewControllerNavigator() -> Navigator {
        let navigator = Navigator(
            session: session,
            modalSession: modalSession,
            delegate: customViewControllerDelegate,
            configuration: .init(name: "Test", startLocation: oneURL)
        )
        navigator.hierarchyController = NavigationHierarchyController(
            delegate: navigator,
            navigationController: navigationController,
            modalNavigationController: modalNavigationController
        )
        return navigator
    }

    // Simulate a "real" app so presenting view controllers works under test.
    private func loadNavigationControllerInWindow() {
        loadNavigationControllerInWindow(navigationController)
    }

    private func loadNavigationControllerInWindow(_ navigationController: UINavigationController) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.loadViewIfNeeded()
    }

    private func assertVisited(url: URL, on context: Context) {
        switch context {
        case .main:
            XCTAssertEqual(navigator.session.activeVisitable?.initialVisitableURL, url)
        case .modal:
            XCTAssertEqual(navigator.modalSession.activeVisitable?.initialVisitableURL, url)
        }
    }
}

// MARK: - EmptyNavigationDelegate

private class EmptyNavigationDelegate: NavigationHierarchyControllerDelegate {
    func visit(_: Visitable, on: NavigationHierarchyController.NavigationStackType, with: VisitOptions) {}
    func refreshVisitable(navigationStack: NavigationHierarchyController.NavigationStackType, newTopmostVisitable: any Visitable) { }
}

// MARK: - VisitProposal extension

extension VisitProposal {
    init(path: String = "",
         queryItems: [URLQueryItem]? = nil,
         action: VisitAction = .advance,
         context: Navigation.Context = .default,
         presentation: Navigation.Presentation = .default,
         redirected: Bool = false,
         additionalProperties: [String: AnyHashable] = [:]) {
        let baseURL = URL(string: "https://example.com")!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = path.hasPrefix("/") ? path : "/\(path)"
        components?.queryItems = queryItems
        let url = components!.url!
        let response = redirected ? VisitResponse(statusCode: 200, redirected: true) : nil
        let options = VisitOptions(action: action, response: response)
        let defaultProperties: PathProperties = [
            "context": context.rawValue,
            "presentation": presentation.rawValue
        ]
        let properties = defaultProperties.merging(additionalProperties) { (_, new) in new }

        self.init(url: url, options: options, properties: properties)
    }
}

// MARK: - AlertControllerDelegate

private class AlertControllerDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        if proposal.url.path == "/alert" {
            return .acceptCustom(UIAlertController(title: "Alert", message: nil, preferredStyle: .alert))
        }

        return .accept
    }
}

// MARK: - CustomViewControllerDelegate

/// A non-`Visitable` custom view controller. Two instances at different URLs share a type, so
/// the navigator must rely on the stamped routed location — not type equality — to tell them apart.
private final class CustomViewController: UIViewController {}

private class CustomViewControllerDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        .acceptCustom(CustomViewController())
    }
}

// MARK: - RedirectProposalRecordingDelegate

private final class RedirectProposalRecordingDelegate: NavigatorDelegate {
    private(set) var redirectProposals = [VisitProposal]()

    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        if proposal.isRedirect {
            redirectProposals.append(proposal)
        }

        return .accept
    }
}

// MARK: - DelayedDismissalNavigationController

private final class DelayedDismissalNavigationController: TestableNavigationController {
    private var dismissalCompletion: (() -> Void)?

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissalCompletion = completion
    }

    func completeDismissal() {
        presentedViewController = nil
        dismissalCompletion?()
        dismissalCompletion = nil
    }
}
