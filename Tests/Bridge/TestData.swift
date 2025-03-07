import Foundation
@testable import HotwireNative

final class AppBridgeDestination: BridgeDestination {}

final class OneBridgeComponent: BridgeComponent {
    override static var name: String { "one" }

    required init(destination: BridgeDestination, delegate: BridgingDelegate) {
        super.init(destination: destination, delegate: delegate)
    }

    override func onReceive(message: Message) {}
}

final class TwoBridgeComponent: BridgeComponent {
    override static var name: String { "two" }

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

extension Message {
    static let test = Message(
        id: "1",
        component: "two",
        event: "connect",
        metadata: .init(url: "https://37signals.com"),
        jsonData: """
            {"title":"Page-title","subtitle":"Page-subtitle"}
        """
    )
}
