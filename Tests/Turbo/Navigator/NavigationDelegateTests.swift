@testable import HotwireNative
import SafariServices
import XCTest

final class NavigationDelegateTests: XCTestCase {
    override func setUp() async throws {
        spyDelegate = NavigatorDelegateSpy()
        navigator = Navigator(
            session: session,
            modalSession: modalSession,
            delegate: spyDelegate,
            configuration: .init(name: "test", startLocation: URL(string: "http://example.com")!)
        )
    }
    
    override func tearDown() async throws {
        spyDelegate.handlerExecuted = false
    }
    
    func test_controllerForProposal_defaultsToVisitableViewController() throws {
        let url = URL(string: "http://example.com/testing")!
        let proposal = VisitProposal(url: url, options: VisitOptions())
        
        navigator.route(proposal)

        XCTAssertEqual(spyDelegate.handlerExecuted, true)
    }
    
    private var navigator: Navigator!
    private var spyDelegate: NavigatorDelegateSpy!
    
    private let session = Session(webView: Hotwire.config.makeWebView())
    private let modalSession = Session(webView: Hotwire.config.makeWebView())
    
    class NavigatorDelegateSpy: NavigatorDelegate {
        public var handlerExecuted = false
        
        func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
            self.handlerExecuted = true
            return .accept
        }
    }
}
