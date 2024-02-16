import Foundation
import WebKit
@testable import Strada

final class BridgeDelegateSpy: BridgingDelegate {
    let location: String = ""
    let destination: BridgeDestination = AppBridgeDestination()
    var webView: WKWebView? = nil
    
    var replyWithMessageWasCalled = false
    var replyWithMessageArg: Message?
    
    func webViewDidBecomeActive(_ webView: WKWebView) {
        
    }
    
    func webViewDidBecomeDeactivated() {
        
    }
    
    func reply(with message: Message) -> Bool {
        replyWithMessageWasCalled = true
        replyWithMessageArg = message
        
        return true
    }
    
    func onViewDidLoad() {
        
    }
    
    func onViewWillAppear() {
        
    }
    
    func onViewDidAppear() {
        
    }
    
    func onViewWillDisappear() {
        
    }
    
    func onViewDidDisappear() {
        
    }
    
    func component<C>() -> C? where C : BridgeComponent {
        return nil
    }
    
    func bridgeDidInitialize() {
        
    }
    
    func bridgeDidReceiveMessage(_ message: Message) -> Bool {
        return false
    }
}
