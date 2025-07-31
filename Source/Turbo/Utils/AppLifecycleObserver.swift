import Foundation
import UIKit

protocol AppLifecycleObserverDelegate: AnyObject {
    func appDidEnterBackground()
    func appWillEnterForeground()
}

final class AppLifecycleObserver {
    weak var delegate: AppLifecycleObserverDelegate?

    var appState: UIApplication.State {
        UIApplication.shared.applicationState
    }

    init(delegate: AppLifecycleObserverDelegate? = nil) {
        self.delegate = delegate

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        delegate?.appDidEnterBackground()
    }

    @objc private func appWillEnterForeground() {
        delegate?.appWillEnterForeground()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
