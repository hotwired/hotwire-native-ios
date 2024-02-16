import Foundation
import os.log

enum StradaLogger {
    static var debugLoggingEnabled: Bool = false {
        didSet {
            logger = debugLoggingEnabled ? enabledLogger : disabledLogger
        }
    }
    static let enabledLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Strada")
    static let disabledLogger = Logger(.disabled)
}

var logger = StradaLogger.disabledLogger
