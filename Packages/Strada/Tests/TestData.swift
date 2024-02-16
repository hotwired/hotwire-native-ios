import Foundation
@testable import Strada

final class AppBridgeDestination: BridgeDestination {}

final class OneBridgeComponent: BridgeComponent {
    static override var name: String { "one" }
    
    required init(destination: BridgeDestination, delegate: BridgingDelegate) {
        super.init(destination: destination, delegate: delegate)
    }
    
    override func onReceive(message: Message) {}
}

final class TwoBridgeComponent: BridgeComponent {
    static override var name: String { "two" }
    
    required init(destination: BridgeDestination, delegate: BridgingDelegate) {
        super.init(destination: destination, delegate: delegate)
    }
    
    override func onReceive(message: Message) {}
}

struct PageData: Codable {
    let metadata: InternalMessage.Metadata
    let title: String
    let subtitle: String
    let actions: [String]
}

struct MessageData: Codable, Equatable {
    let title: String
    let subtitle: String
    let actionName: String
}
