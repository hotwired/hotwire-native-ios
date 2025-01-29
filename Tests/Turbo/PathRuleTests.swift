@testable import HotwireNative
import XCTest

class PathRuleTests: XCTestCase {
    func test_subscript_returnsAStringValueForKey() {
        let rule = PathRule(patterns: ["^/new$"], properties: ["color": "blue", "modal": false])

        XCTAssertEqual(rule["color"], "blue")
        XCTAssertNil(rule["modal"])
    }

    func test_match_whenPathMatchesSinglePattern_returnsTrue() {
        let rule = PathRule(patterns: ["^/new$"], properties: [:])

        XCTAssertTrue(rule.match(path: "/new"))
    }

    func test_match_whenPathMatchesAnyPatternInArray_returnsTrue() {
        let rule = PathRule(patterns: ["^/new$", "^/edit"], properties: [:])

        XCTAssertTrue(rule.match(path: "/edit/1"))
    }

    func test_match_whenPathDoesntMatchAnyPatterns_returnsFalse() {
        let rule = PathRule(patterns: ["^/new/bar"], properties: [:])

        XCTAssertFalse(rule.match(path: "/new"))
        XCTAssertFalse(rule.match(path: "foo"))
    }

    func test_recedeHistoricalLocation() {
        let rule = PathRule.recedeHistoricalLocation
        XCTAssertEqual(rule.patterns, ["/recede_historical_location"])
        XCTAssertEqual(rule.properties, ["presentation": "pop",
                                         "historical_location": true])
    }

    func test_refreshHistoricalLocation() {
        let rule = PathRule.refreshHistoricalLocation
        XCTAssertEqual(rule.patterns, ["/refresh_historical_location"])
        XCTAssertEqual(rule.properties, ["presentation": "refresh",
                                         "historical_location": true])
    }

    func test_resumeHistoricalLocation() {
        let rule = PathRule.resumeHistoricalLocation
        XCTAssertEqual(rule.patterns, ["/resume_historical_location"])
        XCTAssertEqual(rule.properties, ["presentation": "none",
                                         "historical_location": true])
    }

    func test_defaultHistoricalLocationRules() {
        XCTAssertEqual(PathRule.defaultServerRoutes.count, 3)
        let expectedRules: [PathRule] = [
            PathRule.recedeHistoricalLocation,
            PathRule.resumeHistoricalLocation,
            PathRule.refreshHistoricalLocation
        ]

        if #available(iOS 16.0, *) {
            XCTAssertTrue(PathRule.defaultServerRoutes.contains(expectedRules))
        }
    }
}
