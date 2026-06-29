import XCTest
@testable import HotwireNative

final class LoadErrorTests: XCTestCase {

    // MARK: - errorDescription

    func test_errorDescription_notPresent() {
        XCTAssertEqual(LoadError.notPresent.errorDescription, "The page could not be loaded because Turbo is not present.")
    }

    func test_errorDescription_notReady() {
        XCTAssertEqual(LoadError.notReady.errorDescription, "The page could not be loaded because Turbo is not ready.")
    }

    func test_errorDescription_contentTypeMismatch() {
        XCTAssertEqual(LoadError.contentTypeMismatch.errorDescription, "The server returned an invalid content type.")
    }

    func test_errorDescription_invalidResponse() {
        XCTAssertEqual(LoadError.invalidResponse.errorDescription, "The server returned an invalid response.")
    }

    // MARK: - description

    func test_description_notPresent() {
        XCTAssertEqual(LoadError.notPresent.title, "Turbo Not Present")
    }

    func test_description_notReady() {
        XCTAssertEqual(LoadError.notReady.title, "Turbo Not Ready")
    }

    func test_description_contentTypeMismatch() {
        XCTAssertEqual(LoadError.contentTypeMismatch.title, "Content Type Mismatch")
    }

    func test_description_invalidResponse() {
        XCTAssertEqual(LoadError.invalidResponse.title, "Invalid Response")
    }
}
