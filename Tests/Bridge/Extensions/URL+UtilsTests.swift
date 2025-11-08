@testable import HotwireNative
import XCTest

class URL_UtilsTests: XCTestCase {

    func testCompatiblePath_withoutTrailingSlash() {
        let url = URL(string: "https://www.example.com/path/to/resource")!
        let expectedPath = "/path/to/resource"
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Path should not have a trailing slash.")
    }

    func testCompatiblePath_withTrailingSlash() {
        let url = URL(string: "https://www.example.com/path/to/directory/")!
        let expectedPath = "/path/to/directory/"
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Path should preserve the trailing slash.")
    }
    
    func testCompatiblePath_rootPathWithSlash() {
        let url = URL(string: "https://www.example.com/")!
        let expectedPath = "/"
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Root path should be a single slash.")
    }
    
    func testCompatiblePath_domainOnly() {
        let url = URL(string: "https://www.example.com")!
        let expectedPath = ""
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Path should be empty for a URL with no path component.")
    }

    func testCompatiblePath_withTrailingSlash_andQueryParameters() {
        let url = URL(string: "https://www.example.com/path/to/directory/?param1=value1&param2=value2")!
        let expectedPath = "/path/to/directory/"
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Path should preserve the trailing slash and ignore query parameters.")
    }
    
    func testCompatiblePath_withoutTrailingSlash_andQueryParameters() {
        let url = URL(string: "https://www.example.com/path/to/resource?param1=value1")!
        let expectedPath = "/path/to/resource"
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Path should not have a trailing slash and ignore query parameters.")
    }
    
    func testCompatiblePath_pathWithMultipleSlashes() {
        let url = URL(string: "https://www.example.com/path//to/resource/")!
        let expectedPath = "/path//to/resource/"
        XCTAssertEqual(url.pathPreservingSlash, expectedPath, "Path should preserve all slashes as they are.")
    }
}
