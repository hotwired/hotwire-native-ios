import OSLog

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

private extension LogLevel {
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
