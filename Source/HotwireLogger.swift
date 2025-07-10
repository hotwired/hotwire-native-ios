import Foundation
import OSLog

public enum LogLevel {
    case debug, info, warning, error
    
    var osLogLevel: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .error
        case .error:
            return .error
        }
    }
}

public protocol Logger {
    func log(message: String, level: LogLevel, file: String, function: String, line: UInt)
    func debug(_ message: String, file: String, function: String, line: UInt)
    func info(_ message: String, file: String, function: String, line: UInt)
    func warning(_ message: String, file: String, function: String, line: UInt)
    func error(_ message: String, file: String, function: String, line: UInt)
}

public struct OSLogWrapper: Logger {
    private let osLogger: os.Logger
    
    public init(subsystem: String, category: String) {
        self.osLogger = os.Logger(subsystem: subsystem, category: category)
    }
    
    public static var disabled: Logger {
        OSLogWrapper(osLogger: os.Logger(.disabled))
    }
    
    public func log(message: String, level: LogLevel, file: String, function: String, line: UInt) {
        osLogger.log(level: level.osLogLevel, "\(message)")
    }
    
    private init(osLogger: os.Logger) {
        self.osLogger = osLogger
    }
}

extension Logger {
    public func debug(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message: message, level: .debug, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message: message, level: .info, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message: message, level: .warning, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(message: message, level: .error, file: file, function: function, line: line)
    }
}

enum HotwireLogger {
    static let enabledLogger = OSLogWrapper(subsystem: Bundle.module.bundleIdentifier!, category: "HotwireNative")
    static let disabledLogger = OSLogWrapper.disabled
    
    static func update(debugLoggingEnabled: Bool, log: Logger?) {
        if debugLoggingEnabled {
            logger = log ?? enabledLogger
        } else {
            logger = disabledLogger
        }
    }
}

var logger: Logger = HotwireLogger.disabledLogger
