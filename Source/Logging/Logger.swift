import Foundation

public protocol Logger {
    func log(message: String, level: LogLevel, file: String, function: String, line: UInt)
    func debug(_ message: String, file: String, function: String, line: UInt)
    func info(_ message: String, file: String, function: String, line: UInt)
    func warning(_ message: String, file: String, function: String, line: UInt)
    func error(_ message: String, file: String, function: String, line: UInt)
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
