import Foundation
import HotwireNative
import XCTest

class UserAgentTests: XCTestCase {
    func testUserAgentSubstringWithTwoComponents() {
        let userAgentSubstring = UserAgent.userAgentSubstring(for: [OneBridgeComponent.self, TwoBridgeComponent.self])
        XCTAssertEqual(userAgentSubstring, "bridge-components: [one two]")
    }

    func testUserAgentSubstringWithNoComponents() {
        let userAgentSubstring = UserAgent.userAgentSubstring(for: [])
        XCTAssertEqual(userAgentSubstring, "bridge-components: []")
    }
}
