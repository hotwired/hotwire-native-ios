@testable import HotwireNative
import SafariServices
import XCTest
import WebKit

final class NavigationDelegateTests: Navigator {
    func test_controllerForProposal_defaultsToVisitableViewController() throws {
        let url = URL(string: "https://example.com")!

        let proposal = VisitProposal(url: url, options: VisitOptions())
        let result = delegate.handle(proposal: proposal)

        XCTAssertEqual(result, .accept)
    }

    func test_webNavigationDecision_defaultsToDefaultDecision() throws {
        let action = WKNavigationAction()
        let result = delegate.webNavigationDecision(for: action)

        XCTAssertEqual(result, .defaultDecision(for: action))
    }
}
