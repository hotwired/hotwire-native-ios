import XCTest
import WebKit
@testable import Strada

class BridgeTests: XCTestCase {
    func testInitWithANewWebViewAutomaticallyLoadsIntoWebView() {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)
        
        Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }
    
    func testInitWithTheSameWebViewDoesNotLoadTwice() {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)
        
        Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
        
        Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }
    
    func testRegisterComponentCallsJavaScriptFunction() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        bridge.register(component: "test")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.register(\"test\")")
    }
    
    func testRegisterComponentsCallsJavaScriptFunction() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        bridge.register(components: ["one", "two"])
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.register([\"one\",\"two\"])")
    }
    
    func testUnregisterComponentCallsJavaScriptFunction() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        bridge.unregister(component: "test")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.unregister(\"test\")")
    }
    
    func testSendCallsJavaScriptFunction() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        let data = """
        {"title":"Page-title"}
        """
        let metadata = Message.Metadata(url: "https://37signals.com")
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: data)

        
        bridge.reply(with: message)
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.replyWith({\"component\":\"page\",\"event\":\"connect\",\"data\":{\"title\":\"Page-title\"},\"id\":\"1\"})")
    }
    
    func testEvaluateJavaScript() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        bridge.evaluate(javaScript: "test(1,2,3)")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "test(1,2,3)")
    }
    
    func testEvaluateJavaScriptReturnsErrorForNoWebView() {
        let bridge = Bridge(webView: WKWebView())
        bridge.webView = nil
        let expectation = self.expectation(description: "error handler")
        
        bridge.evaluate(function: "test", arguments: []) { (result, error) in
            XCTAssertEqual(error! as! BridgeError, BridgeError.missingWebView)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testEvaluateFunction() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        bridge.evaluate(function: "test", arguments: [1, 2, 3])
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "test(1,2,3)")
    }
    
    func testEvaluateFunctionCallsCompletionHandler() {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        
        let expectation = self.expectation(description: "completion handler")
        
        bridge.evaluate(function: "test", arguments: []) { (result, error) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
}

private final class TestWebView: WKWebView {
    var lastEvaluatedJavaScript: String?
    
    override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        lastEvaluatedJavaScript = javaScriptString
        super.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
}
