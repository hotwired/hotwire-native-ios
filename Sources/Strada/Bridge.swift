import Foundation
import WebKit

public enum BridgeError: Error {
    case missingWebView
}

protocol Bridgable: AnyObject {
    var delegate: BridgeDelegate? { get set }
    var webView: WKWebView? { get }
    
    func register(component: String)
    func register(components: [String])
    func unregister(component: String)
    func reply(with message: Message)
}

/// `Bridge` is the object for configuring a web view and
/// the channel for sending/receiving messages
public final class Bridge: Bridgable {
    typealias CompletionHandler = (_ result: Any?, _ error: Error?) -> Void
    
    weak var delegate: BridgeDelegate?
    weak var webView: WKWebView?
    
    public static func initialize(_ webView: WKWebView) {
        if getBridgeFor(webView) == nil {
            initialize(Bridge(webView: webView))
        }
    }
    
    init(webView: WKWebView) {
        self.webView = webView
        loadIntoWebView()
    }
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: scriptHandlerName)
    }
    
    // MARK: - Internal API
    
    /// Register a single component
    /// - Parameter component: Name of a component to register support for
    func register(component: String) {
        callBridgeFunction(.register, arguments: [component])
    }
    
    /// Register multiple components
    /// - Parameter components: Array of component names to register
    func register(components: [String]) {
        callBridgeFunction(.register, arguments: [components])
    }
    
    /// Unregister support for a single component
    /// - Parameter component: Component name
    func unregister(component: String) {
        callBridgeFunction(.unregister, arguments: [component])
    }
    
    /// Send a message through the bridge to the web application
    /// - Parameter message: Message to send
    func reply(with message: Message) {
        logger.debug("bridgeWillReplyWithMessage: \(String(describing: message))")
        let internalMessage = InternalMessage(from: message)
        callBridgeFunction(.replyWith, arguments: [internalMessage.toJSON()])
    }
    
//    /// Convenience method to reply to a previously received message. Data will be replaced,
//    /// while id, component, and event will remain the same
//    /// - Parameter message: Message to reply to
//    /// - Parameter data: Data to send with reply
//    public func reply(to message: Message, with data: MessageData) {
//        let replyMessage = message.replacing(data: data)
//        callBridgeFunction("send", arguments: [replyMessage.toJSON()])
//    }

    /// Evaluates javaScript string directly as passed in sending through the web view
    func evaluate(javaScript: String, completion: CompletionHandler? = nil) {
        guard let webView = webView else {
            completion?(nil, BridgeError.missingWebView)
            return
        }
        
        webView.evaluateJavaScript(javaScript) { result, error in
            if let error = error {
                logger.error("Error evaluating JavaScript: \(error)")
            }
            
            completion?(result, error)
        }
    }
    
    /// Evaluates a JavaScript function with optional arguments by encoding the arguments
    /// Function should not include the parens
    /// Usage: evaluate(function: "console.log", arguments: ["test"])
    func evaluate(function: String, arguments: [Any] = [], completion: CompletionHandler? = nil) {
        evaluate(javaScript: JavaScript(functionName: function, arguments: arguments), completion: completion)
    }

    static func initialize(_ bridge: Bridge) {
        instances.append(bridge)
        instances.removeAll { $0.webView == nil }
    }

    static func getBridgeFor(_ webView: WKWebView) -> Bridge? {
        return instances.first { $0.webView == webView }
    }
    
    // MARK: Private

    private static var instances: [Bridge] = []
    /// This needs to match whatever the JavaScript file uses
    private let bridgeGlobal = "window.nativeBridge"
    
    /// The webkit.messageHandlers name
    private let scriptHandlerName = "strada"
    
    private func callBridgeFunction(_ function: JavaScriptBridgeFunction, arguments: [Any]) {
        let js = JavaScript(object: bridgeGlobal, functionName: function.rawValue, arguments: arguments)
        evaluate(javaScript: js)
    }

    // MARK: - Configuration
    
    /// Configure the bridge in the provided web view
    private func loadIntoWebView() {
        guard let configuration = webView?.configuration else { return }

        // Install user script and message handlers in web view
        if let userScript = makeUserScript() {
            configuration.userContentController.addUserScript(userScript)
        }
        
        let scriptMessageHandler = ScriptMessageHandler(delegate: self)
        configuration.userContentController.add(scriptMessageHandler, name: scriptHandlerName)
    }

    private func makeUserScript() -> WKUserScript? {
        guard
            let path = PathLoader().pathFor(name: "strada", fileType: "js") else {
                return nil
        }
        
        do {
            let source = try String(contentsOfFile: path)
            return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        } catch {
            assertionFailure("Could not open strada.js: \(error)")
            return nil
        }
    }
    
    // MARK: - JavaScript Evaluation
    
    private func evaluate(javaScript: JavaScript, completion: CompletionHandler? = nil) {
        do {
            evaluate(javaScript: try javaScript.toString(), completion: completion)
        } catch {
            logger.error("Error evaluating JavaScript: \(String(describing: javaScript)), error: \(error)")
            completion?(nil, error)
        }
    }
    
    private enum JavaScriptBridgeFunction: String {
        case register
        case unregister
        case replyWith
    }
}

extension Bridge: ScriptMessageHandlerDelegate {
    func scriptMessageHandlerDidReceiveMessage(_ scriptMessage: WKScriptMessage) {
        if let event = scriptMessage.body as? String,
            event == "ready" {
            delegate?.bridgeDidInitialize()
            return
        }
        
        if let message = InternalMessage(scriptMessage: scriptMessage) {
            delegate?.bridgeDidReceiveMessage(message.toMessage())
            return
        }
        
        logger.warning("Unhandled message received: \(String(describing: scriptMessage.body))")
    }
}
