import XCTest
@testable import HotwireNative

final class CustomLoggerTests: XCTestCase {
    private var spy: LoggerSpy!

    override func setUp() {
        super.setUp()
        spy = LoggerSpy()
        resetLoggingConfig()
    }

    override func tearDown() {
        resetLoggingConfig()
        spy = nil
        super.tearDown()
    }

    func test_customLogger_receivesMessages_whenDebugLoggingEnabled() {
        Hotwire.config.debugLoggingEnabled = true
        Hotwire.config.log = spy

        logger.debug("debug message")
        logger.info("info message")
        logger.warning("warning message")
        logger.error("error message")

        XCTAssertEqual(spy.messages(for: .debug), ["debug message"])
        XCTAssertEqual(spy.messages(for: .info), ["info message"])
        XCTAssertEqual(spy.messages(for: .warning), ["warning message"])
        XCTAssertEqual(spy.messages(for: .error), ["error message"])
    }

    func test_customLogger_isWired_regardlessOfSetterOrder() {
        // Set the logger before enabling debug logging.
        Hotwire.config.log = spy
        Hotwire.config.debugLoggingEnabled = true

        logger.debug("message")

        XCTAssertEqual(spy.messages(for: .debug), ["message"])
    }

    func test_customLogger_isNotUsed_whenDebugLoggingDisabled() {
        Hotwire.config.debugLoggingEnabled = false
        Hotwire.config.log = spy

        logger.debug("debug message")
        logger.error("error message")

        XCTAssertTrue(spy.allMessages.isEmpty)
    }

    func test_disablingDebugLogging_stopsRoutingToCustomLogger() {
        Hotwire.config.debugLoggingEnabled = true
        Hotwire.config.log = spy
        logger.debug("while enabled")

        Hotwire.config.debugLoggingEnabled = false
        logger.debug("while disabled")

        XCTAssertEqual(spy.allMessages, ["while enabled"])
    }

    func test_clearingCustomLogger_fallsBackToEnabledLogger() {
        Hotwire.config.debugLoggingEnabled = true
        Hotwire.config.log = spy
        Hotwire.config.log = nil

        logger.debug("message")

        // The spy is no longer wired; messages route to the default enabled logger.
        XCTAssertTrue(spy.allMessages.isEmpty)
    }

    private func resetLoggingConfig() {
        Hotwire.config.debugLoggingEnabled = false
        Hotwire.config.log = nil
    }
}

private final class LoggerSpy: Logger {
    private(set) var allMessages: [String] = []
    private var debugMessages: [String] = []
    private var infoMessages: [String] = []
    private var warningMessages: [String] = []
    private var errorMessages: [String] = []

    func log(message: String, level: LogLevel, file: String, function: String, line: UInt) {
        allMessages.append(message)
        switch level {
        case .debug: debugMessages.append(message)
        case .info: infoMessages.append(message)
        case .warning: warningMessages.append(message)
        case .error: errorMessages.append(message)
        }
    }

    func messages(for level: LogLevel) -> [String] {
        switch level {
        case .debug: return debugMessages
        case .info: return infoMessages
        case .warning: return warningMessages
        case .error: return errorMessages
        }
    }
}
