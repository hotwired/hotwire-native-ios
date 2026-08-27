import WebKit

protocol ScriptMessageHandlerDelegate: AnyObject {
    func scriptMessageHandlerDidReceiveMessage(_ scriptMessage: WKScriptMessage)
}

// Avoids retain cycle caused by WKUserContentController
final class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: ScriptMessageHandlerDelegate?

    init(delegate: ScriptMessageHandlerDelegate?) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive scriptMessage: WKScriptMessage) {
        guard scriptMessage.frameInfo.isMainFrame else {
            let origin = scriptMessage.frameInfo.securityOrigin
            logger.warning("scriptMessageRefusedForSubframeOrigin: \(origin.protocol)://\(origin.host):\(origin.port)")
            return
        }

        delegate?.scriptMessageHandlerDidReceiveMessage(scriptMessage)
    }
}
