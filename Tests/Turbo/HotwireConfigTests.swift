import XCTest
@testable import HotwireNative

final class HotwireConfigTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Hotwire.config.logger = nil
    }
    
    func testUserAgent() {
        var config = HotwireConfig()
        config.applicationUserAgentPrefix = "TestApp/1.0"
        
        let testComponent = MockBridgeComponent.self
        Hotwire.registerBridgeComponents([testComponent])
        
        XCTAssertEqual(config.userAgent, "TestApp/1.0 Hotwire Native iOS; Turbo Native iOS; bridge-components: [MockComponent]")
    }
    
    func testCustomLogger() {
        let spy = CustomLoggerSpy()
        
        // Test that messages are captured when logger is set
        Hotwire.config.logger = spy
        
        logger.debug("test debug message")
        logger.error("test error message")
        logger.warning("test warning message")
        
        XCTAssertEqual(spy.debugMessages, ["test debug message"])
        XCTAssertEqual(spy.errorMessages, ["test error message"])
        XCTAssertEqual(spy.warningMessages, ["test warning message"])
    }
}

private class MockBridgeComponent: BridgeComponent {
    static override var name: String { "MockComponent" }
}

private class CustomLoggerSpy: HotwireLogger {
    var debugMessages: [String] = []
    var infoMessages: [String] = []
    var noticeMessages: [String] = []
    var errorMessages: [String] = []
    var warningMessages: [String] = []
    var faultMessages: [String] = []
    
    func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        debugMessages.append(message)
    }
    
    func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        infoMessages.append(message)
    }
    
    func notice(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        noticeMessages.append(message)
    }
    
    func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        errorMessages.append(message)
    }
    
    func warning(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        warningMessages.append(message)
    }
    
    func fault(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        faultMessages.append(message)
    }
}
