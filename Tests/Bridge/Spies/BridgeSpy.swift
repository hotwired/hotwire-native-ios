import Foundation
import WebKit
@testable import HotwireNative

final class BridgeSpy: Bridgable {
    var delegate: BridgeDelegate? = nil
    var webView: WKWebView? = nil
    
    var registerComponentWasCalled = false
    var registerComponentArg: String? = nil
    
    var registerComponentsWasCalled = false {
        didSet {
            if registerComponentsWasCalled {
                registerComponentsContinuation?.resume()
                registerComponentsContinuation = nil
            }
        }
    }
    var registerComponentsContinuation: CheckedContinuation<Void, Never>?
    var registerComponentsArg: [String]? = nil
    
    var unregisterComponentWasCalled = false
    var unregisterComponentArg: String? = nil
    
    var replyWithMessageWasCalled = false
    var replyWithMessageArg: Message? = nil
    
    func register(component: String) {
        registerComponentWasCalled = true
        registerComponentArg = component
    }
    
    func register(components: [String]) {
        registerComponentsWasCalled = true
        registerComponentsArg = components
    }
    
    func unregister(component: String) {
        unregisterComponentWasCalled = true
        unregisterComponentArg = component
    }
    
    func reply(with message: Message) {
        replyWithMessageWasCalled = true
        replyWithMessageArg = message
    }
}
