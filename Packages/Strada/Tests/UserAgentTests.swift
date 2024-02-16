import Foundation
import XCTest
@testable import Strada

class UserAgentTests: XCTestCase {
    func testUserAgentSubstringWithTwoComponents() {
        let userAgentSubstring = Strada.userAgentSubstring(for: [OneBridgeComponent.self, TwoBridgeComponent.self])
        XCTAssertEqual(userAgentSubstring, "bridge-components: [one two]")
    }
    
    func testUserAgentSubstringWithNoComponents() {
        let userAgentSubstring = Strada.userAgentSubstring(for: [])
        XCTAssertEqual(userAgentSubstring, "bridge-components: []")
    }
}
