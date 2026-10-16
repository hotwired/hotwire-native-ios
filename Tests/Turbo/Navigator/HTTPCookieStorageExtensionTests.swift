@testable import HotwireNative
import XCTest

final class HTTPCookieStorageExtensionTests: XCTestCase {
    private let url = URL(string: "https://example.com/page")!
    private let storage = HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: "HTTPCookieStorageExtensionTests")

    override func setUp() {
        storage.cookies?.forEach(storage.deleteCookie)
    }

    func test_replaceCookies_removesCookiesNoLongerPresent() {
        storage.setCookies([cookie("session", "signed-in")], for: url, mainDocumentURL: url)

        storage.replaceCookies(for: url, with: [cookie("other", "value")])

        XCTAssertEqual(storage.cookies(for: url)?.map(\.name), ["other"])
    }

    func test_replaceCookies_updatesChangedValues() {
        storage.setCookies([cookie("session", "signed-in")], for: url, mainDocumentURL: url)

        storage.replaceCookies(for: url, with: [cookie("session", "signed-out")])

        XCTAssertEqual(storage.cookies(for: url)?.map(\.value), ["signed-out"])
    }

    func test_replaceCookies_leavesOtherDomainsAlone() {
        let otherURL = URL(string: "https://other.example.org")!
        storage.setCookies([cookie("other", "value", domain: "other.example.org")], for: otherURL, mainDocumentURL: otherURL)

        storage.replaceCookies(for: url, with: [])

        XCTAssertEqual(storage.cookies(for: otherURL)?.map(\.name), ["other"])
    }

    private func cookie(_ name: String, _ value: String, domain: String = "example.com") -> HTTPCookie {
        HTTPCookie(properties: [.name: name, .value: value, .domain: domain, .path: "/"])!
    }
}
