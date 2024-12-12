import Foundation
@testable import HotwireNative
import XCTest

class UserAgentTests: XCTestCase {
    func testUserAgentSubstringWithNoComponents() {
        let userAgentSubstring = UserAgent.build(
            componentTypes: [],
            applicationPrefix: nil
        )
        XCTAssertEqual(userAgentSubstring, "Hotwire Native iOS; Turbo Native iOS; bridge-components: []")
    }

    func testUserAgentSubstringWithTwoComponents() {
        let userAgentSubstring = UserAgent.build(
            componentTypes: [OneBridgeComponent.self, TwoBridgeComponent.self],
            applicationPrefix: nil
        )
        XCTAssertEqual(userAgentSubstring, "Hotwire Native iOS; Turbo Native iOS; bridge-components: [one two]")
    }

    func testUserAgentSubstringCustomPrefix() {
        let userAgentSubstring = UserAgent.build(
            componentTypes: [OneBridgeComponent.self, TwoBridgeComponent.self],
            applicationPrefix: "Hotwire Demo;"
        )
        XCTAssertEqual(userAgentSubstring, "Hotwire Demo; Hotwire Native iOS; Turbo Native iOS; bridge-components: [one two]")
    }
}
