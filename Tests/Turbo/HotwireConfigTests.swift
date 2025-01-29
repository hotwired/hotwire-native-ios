import XCTest
@testable import HotwireNative

final class HotwireConfigTests: XCTestCase {
    func testUserAgent() {
        var config = HotwireConfig()
        config.applicationUserAgentPrefix = "TestApp/1.0"
        
        let testComponent = MockBridgeComponent.self
        Hotwire.registerBridgeComponents([testComponent])
        
        XCTAssertEqual(config.userAgent, "TestApp/1.0 Hotwire Native iOS; Turbo Native iOS; bridge-components: [MockComponent]")
    }
}

private class MockBridgeComponent: BridgeComponent {
    static override var name: String { "MockComponent" }
}
