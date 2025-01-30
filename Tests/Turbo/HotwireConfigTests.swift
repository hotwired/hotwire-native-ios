import XCTest
import WebKit
@testable import HotwireNative

final class HotwireConfigTests: XCTestCase {
    private let sharedProcessPool = WKProcessPool()

    override func setUp() {
        super.setUp()
        Hotwire.bridgeComponentTypes.removeAll()
    }
    
    override func tearDown() {
        Hotwire.bridgeComponentTypes.removeAll()
        HotwireConfig.cachedUserAgent = nil
        super.tearDown()
    }
    
    func testUserAgent() {
        var config = HotwireConfig()
        config.applicationUserAgentPrefix = "TestApp/1.0"
        
        let testComponent = MockBridgeComponent.self
        Hotwire.registerBridgeComponents([testComponent])
        
        XCTAssertEqual(config.userAgent, "TestApp/1.0 Hotwire Native iOS; Turbo Native iOS; bridge-components: [MockComponent]")
    }
    
    func testUserAgentWithWebViewDefault() {
        
        var config = HotwireConfig()
        config.applicationUserAgentPrefix = "TestApp/1.0"
        
        let testComponent = MockBridgeComponent.self
        Hotwire.registerBridgeComponents([testComponent])
        
        let _ = config.makeWebView()
        
        let baseWebView = WKWebView(frame: .zero, configuration: makeWebViewConfiguration(userAgent: config.userAgent))
        let expectedUA = baseWebView.value(forKey: "userAgent") as? String
        
        XCTAssertEqual(config.userAgentWithWebViewDefault, expectedUA)
    }
    
    private func makeWebViewConfiguration(userAgent: String) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = userAgent
        return configuration
    }
}

private class MockBridgeComponent: BridgeComponent {
    static override var name: String { "MockComponent" }
}
