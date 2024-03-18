import Foundation
import HotwireNative
import XCTest

final class ComposerComponent: BridgeComponent {
    override static var name: String { "composer" }
    
    override func onReceive(message: Message) {
        guard let event = InboundEvent(rawValue: message.event) else {
            return
        }
        
        switch event {
        case .connect:
            // Handle connect event if needed.
            break
        }
    }
    
    func selectSender(emailAddress: String) async throws {
        guard let message = receivedMessage(for: InboundEvent.connect.rawValue),
              let senders: [Sender] = message.data()
        else {
            return
        }
        
        guard let sender = senders.first(where: { $0.email == emailAddress }) else {
            return
        }
        
        let newMessage = message.replacing(event: OutboundEvent.selectSender.rawValue,
                                           data: SelectSenderMessageData(selectedIndex: sender.index))
        try await reply(with: newMessage)
    }
    
    func selectedSender() -> String? {
        guard let message = receivedMessage(for: InboundEvent.connect.rawValue),
              let senders: [Sender] = message.data()
        else {
            return nil
        }
        
        guard let selected = senders.first(where: { $0.selected }) else {
            return nil
        }
        
        return selected.email
    }
}

// MARK: Events

extension ComposerComponent {
    private enum InboundEvent: String {
        case connect
    }
    
    private enum OutboundEvent: String {
        case selectSender = "select-sender"
    }
}

// MARK: Message data

extension ComposerComponent {
    private struct Sender: Decodable {
        let email: String
        let index: Int
        let selected: Bool
    }
    
    private struct SelectSenderMessageData: Encodable {
        let selectedIndex: Int
    }
}
