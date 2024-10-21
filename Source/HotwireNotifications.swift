import Foundation
import UIKit

extension NSNotification.Name {
    static let didRegisterBridgeComponents = NSNotification.Name("HotwireNativeDidRegisterBridgeComponents")
}

extension NotificationCenter {
    func removeObservation(_ observationToken: NSObjectProtocol?) {
        guard let observationToken else { return }
        removeObserver(observationToken)
    }

    func removeObservations(_ observationTokens: [NSObjectProtocol?]) {
        for observationToken in observationTokens.compactMap({ $0 }) {
            removeObserver(observationToken)
        }
    }
}

extension NotificationCenter {
    
    func postDidRegisterBridgeComponents() {
        post(name: .didRegisterBridgeComponents, object: nil)
    }
    
    func observeDidRegisterBridgeComponents(reaction: @escaping () -> Void) -> NSObjectProtocol {
        addObserver(forName: .didRegisterBridgeComponents, object: nil, queue: .main) { _ in
            reaction()
        }
    }
}
