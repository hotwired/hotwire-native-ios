@testable import HotwireNative
import SafariServices
import XCTest

final class NavigationDelegateTests: Navigator {
    func test_controllerForProposal_defaultsToVisitableViewController() throws {
        let url = URL(string: "https://example.com")!

        let proposal = VisitProposal(url: url, options: VisitOptions())
        let result = delegate?.handle(proposal: proposal, from: self)

        XCTAssertEqual(result, .accept)
    }
}
