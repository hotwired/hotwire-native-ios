import XCTest
@testable import HotwireNative

final class HotwireConfigTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Hotwire.config.debugLoggingEnabled = false
        Hotwire.config.logDestination = nil
    }
    
    func testUserAgent() {
        var config = HotwireConfig()
        config.applicationUserAgentPrefix = "TestApp/1.0"
        
        let testComponent = MockBridgeComponent.self
        Hotwire.registerBridgeComponents([testComponent])
        
        XCTAssertEqual(config.userAgent, "TestApp/1.0 Hotwire Native iOS; Turbo Native iOS; bridge-components: [MockComponent]")
    }
    
    func testLogDestination() {
        let spy = LogDestinationSpy()
        
        // Test that messages are captured when logDestination is set and logging is enabled
        Hotwire.config.debugLoggingEnabled = true
        Hotwire.config.logDestination = spy
        
        logger.debug("test debug message")
        logger.error("test error message")
        logger.warning("test warning message")
        
        XCTAssertEqual(spy.debugMessages, ["test debug message"])
        XCTAssertEqual(spy.errorMessages, ["test error message"])
        XCTAssertEqual(spy.warningMessages, ["test warning message"])
    }
    
    func testLogDestinationRequiresDebugLoggingEnabled() {
        let spy = LogDestinationSpy()
        
        // Test that messages are NOT captured when debugLoggingEnabled is false
        Hotwire.config.debugLoggingEnabled = false
        Hotwire.config.logDestination = spy
        
        logger.debug("should not be logged")
        logger.error("should not be logged")
        
        XCTAssertTrue(spy.debugMessages.isEmpty)
        XCTAssertTrue(spy.errorMessages.isEmpty)
    }
}

private class MockBridgeComponent: BridgeComponent {
    static override var name: String { "MockComponent" }
}

private class LogDestinationSpy: LogDestination {
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
