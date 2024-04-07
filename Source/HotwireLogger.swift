import Foundation
import os.log

enum HotwireLogger {
    static var debugLoggingEnabled: Bool = false {
        didSet {
            logger = debugLoggingEnabled ? enabledLogger : disabledLogger
        }
    }

    static let enabledLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Hotwire")
    static let disabledLogger = Logger(.disabled)
}

var logger = HotwireLogger.disabledLogger
