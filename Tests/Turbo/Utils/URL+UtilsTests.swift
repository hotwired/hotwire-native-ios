@testable import HotwireNative
import XCTest

class URL_UtilsTests: XCTestCase {
    func testCompatiblePath_withoutTrailingSlash() {
        let url = URL(string: "https://www.example.com/path/to/resource")!
        let expectedPath = "/path/to/resource"

        if #available(iOS 16.0, *) {
            XCTAssertEqual(url.pathPreservingSlash, expectedPath)
        } else {
            XCTAssertEqual(url.pathPreservingSlash, expectedPath)
        }
    }

    func testCompatiblePath_withTrailingSlash() {
        let url = URL(string: "https://www.example.com/path/to/directory/")!
        let expectedPath = "/path/to/directory/"

        if #available(iOS 16.0, *) {
            XCTAssertEqual(url.pathPreservingSlash, expectedPath)
        } else {
            XCTAssertEqual(url.path, "/path/to/directory", "iOS 15 drops the trailing slash.")
            XCTAssertEqual(url.pathPreservingSlash, expectedPath)
        }
    }
}
