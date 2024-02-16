import XCTest
@testable import Strada

class JavaScriptTests: XCTestCase {
    func testToStringWithNoArguments() throws {
        let javaScript = JavaScript(functionName: "test")
        XCTAssertEqual(try javaScript.toString(), "test()")
    }
    
    func testToStringWithEmptyArguments() throws {
        let javaScript = JavaScript(functionName: "test", arguments: [])
        XCTAssertEqual(try javaScript.toString(), "test()")
    }
    
    func testToStringWithOneStringArgument() throws {
        let javaScript = JavaScript(functionName: "test", arguments: ["foo"])
        XCTAssertEqual(try javaScript.toString(), "test(\"foo\")")
    }
    
    func testToStringWithOneNumberArgument() throws {
        let javaScript = JavaScript(functionName: "test", arguments: [1])
        XCTAssertEqual(try javaScript.toString(), "test(1)")
    }
    
    func testToStringWithMultipleArguments() throws {
        let javaScript = JavaScript(functionName: "test", arguments: ["foo", 1])
        XCTAssertEqual(try javaScript.toString(), "test(\"foo\",1)")
    }
    
    func testToStringWithObject() throws {
        let javaScript = JavaScript(object: "window", functionName: "test")
        XCTAssertEqual(try javaScript.toString(), "window.test()")
    }
    
    func testToStringWithNestedObject() throws {
        let javaScript = JavaScript(object: "window.strada", functionName: "test")
        XCTAssertEqual(try javaScript.toString(), "window.strada.test()")
    }
    
    func testToStringWithInvalidArgumentTypeThrowsError() {
        let javaScript = JavaScript(functionName: "test", arguments: [InvalidType()])
        XCTAssertThrowsError(try javaScript.toString())
    }
}

private struct InvalidType {}
