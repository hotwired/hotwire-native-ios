import Foundation

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
