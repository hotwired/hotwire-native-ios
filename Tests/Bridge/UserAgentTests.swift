import Foundation
@testable import HotwireNative
import XCTest

class UserAgentTests: XCTestCase {
    func testUserAgentSubstringWithNoComponents() {
        let userAgentSubstring = UserAgent.build(
            applicationPrefix: nil,
            componentTypes: []
        )
        XCTAssertEqual(userAgentSubstring, "Hotwire Native iOS; Turbo Native iOS; bridge-components: []")
    }

    func testUserAgentSubstringWithTwoComponents() {
        let userAgentSubstring = UserAgent.build(
            applicationPrefix: nil,
            componentTypes: [OneBridgeComponent.self, TwoBridgeComponent.self]
        )
        XCTAssertEqual(userAgentSubstring, "Hotwire Native iOS; Turbo Native iOS; bridge-components: [one two]")
    }

    func testUserAgentSubstringCustomPrefix() {
        let userAgentSubstring = UserAgent.build(
            applicationPrefix: "Hotwire Demo;",
            componentTypes: [OneBridgeComponent.self, TwoBridgeComponent.self]
        )
        XCTAssertEqual(userAgentSubstring, "Hotwire Demo; Hotwire Native iOS; Turbo Native iOS; bridge-components: [one two]")
    }
}
