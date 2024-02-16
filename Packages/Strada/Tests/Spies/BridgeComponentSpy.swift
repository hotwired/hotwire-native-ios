import Foundation
@testable import Strada

final class BridgeComponentSpy: BridgeComponent {
    static override var name: String { "two" }
    
    var onReceiveMessageWasCalled = false
    var onReceiveMessageArg: Message?
    
    var onViewDidLoadWasCalled = false
    var onViewWillAppearWasCalled = false
    var onViewDidAppearWasCalled = false
    var onViewWillDisappearWasCalled = false
    var onViewDidDisappearWasCalled = false
    
    required init(destination: BridgeDestination, delegate: BridgingDelegate) {
        super.init(destination: destination, delegate: delegate)
    }
    
    override func onReceive(message: Message) {
        onReceiveMessageWasCalled = true
        onReceiveMessageArg = message
    }
    
    override func onViewDidLoad() {
        onViewDidLoadWasCalled = true
    }
    
    override func onViewWillAppear() {
        onViewWillAppearWasCalled = true
    }
    
    override func onViewDidAppear() {
        onViewDidAppearWasCalled = true
    }
    
    override func onViewWillDisappear() {
        onViewWillDisappearWasCalled = true
    }
    
    override func onViewDidDisappear() {
        onViewDidDisappearWasCalled = true
    }
}
