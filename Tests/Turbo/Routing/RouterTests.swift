@testable import HotwireNative
import XCTest

final class RouterTests: XCTestCase {
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )
    let url = URL(string: "https://my.app.com/page")!
    var router: Router!
    var navigator: Navigator!

    override func setUp() {
        navigator = Navigator(configuration: navigatorConfiguration)
    }

    func test_no_handlers_stops_navigation() {
        router = Router(decisionHandlers: [])

        let result = router.decideRoute(
            for: url,
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertEqual(result, Router.Decision.cancel)
    }

    func test_no_matching_handlers_stops_navigation() {
        let noMatchSpy1 = NoMatchRouteDecisionHandlerSpy()
        let noMatchSpy2 = NoMatchRouteDecisionHandlerSpy()

        router = Router(
            decisionHandlers: [
                noMatchSpy1,
                noMatchSpy2
            ]
        )

        let result = router.decideRoute(
            for: url,
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertTrue(noMatchSpy1.matchesWasCalled)
        XCTAssertFalse(noMatchSpy1.handleWasCalled)
        XCTAssertTrue(noMatchSpy2.matchesWasCalled)
        XCTAssertFalse(noMatchSpy2.handleWasCalled)
        XCTAssertEqual(result, Router.Decision.cancel)
    }

    func test_only_first_matching_handler_is_executed() {
        let noMatchSpy = NoMatchRouteDecisionHandlerSpy()
        let matchSpy1 = MatchRouteDecisionHandlerSpy()
        let matchSpy2 = MatchRouteDecisionHandlerSpy()

        router = Router(
            decisionHandlers: [
                noMatchSpy,
                matchSpy1,
                matchSpy2
            ]
        )

        let result = router.decideRoute(
            for: url,
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertTrue(noMatchSpy.matchesWasCalled)
        XCTAssertFalse(noMatchSpy.handleWasCalled)
        XCTAssertTrue(matchSpy1.matchesWasCalled)
        XCTAssertTrue(matchSpy1.handleWasCalled)
        XCTAssertFalse(matchSpy2.matchesWasCalled)
        XCTAssertFalse(matchSpy2.handleWasCalled)
        XCTAssertEqual(result, Router.Decision.navigate)
    }
}

final class NoMatchRouteDecisionHandlerSpy: RouteDecisionHandler {
    let name: String = "no-match-spy"
    var matchesWasCalled = false
    var handleWasCalled = false

    func matches(location: URL, configuration: HotwireNative.Navigator.Configuration) -> Bool {
        matchesWasCalled = true
        return false
    }
    
    func handle(location: URL, configuration: HotwireNative.Navigator.Configuration, navigator: HotwireNative.Navigator) -> HotwireNative.Router.Decision {
        handleWasCalled = true
        return .cancel
    }
}

final class MatchRouteDecisionHandlerSpy: RouteDecisionHandler {
    let name: String = "match-spy"
    var matchesWasCalled = false
    var handleWasCalled = false

    func matches(location: URL, configuration: HotwireNative.Navigator.Configuration) -> Bool {
        matchesWasCalled = true
        return true
    }

    func handle(location: URL, configuration: HotwireNative.Navigator.Configuration, navigator: HotwireNative.Navigator) -> HotwireNative.Router.Decision {
        handleWasCalled = true
        return .navigate
    }
}
