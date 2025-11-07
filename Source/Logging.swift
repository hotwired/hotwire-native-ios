import Foundation
import OSLog

enum Logging {
    static let defaultLogger: HotwireLogger = OSLogHotwireLogger(
        logger: Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "Hotwire"
        )
    )
}

var logger: HotwireLogger {
    Hotwire.config.logger
}

public protocol HotwireLogger {
    func debug(_ message: String, file: StaticString, function: StaticString, line: UInt)
    func info(_ message: String, file: StaticString, function: StaticString, line: UInt)
    func notice(_ message: String, file: StaticString, function: StaticString, line: UInt)
    func error(_ message: String, file: StaticString, function: StaticString, line: UInt)
    func warning(_ message: String, file: StaticString, function: StaticString, line: UInt)
    func fault(_ message: String, file: StaticString, function: StaticString, line: UInt)
}

extension HotwireLogger {
    public func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.debug(message, file: file, function: function, line: line)
    }
    public func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.info(message, file: file, function: function, line: line)
    }
    public func notice(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.notice(message, file: file, function: function, line: line)
    }
    public func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.error(message, file: file, function: function, line: line)
    }
    public func warning(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.warning(message, file: file, function: function, line: line)
    }
}

public struct OSLogHotwireLogger: HotwireLogger {
    public let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    public func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logger.debug("\(message)")
    }
    
    public func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logger.info("\(message)")
    }
    
    public func notice(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logger.notice("\(message)")
    }
    
    public func warning(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logger.warning("\(message)")
    }
    
    public func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logger.error("\(message)")
    }
    
    public func fault(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logger.fault("\(message)")
    }
}
