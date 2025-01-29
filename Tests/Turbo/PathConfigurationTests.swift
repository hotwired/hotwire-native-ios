@testable import HotwireNative
import XCTest

class PathConfigurationTests: XCTestCase {
    private let fileURL = Bundle.module.url(forResource: "test-configuration", withExtension: "json", subdirectory: "Fixtures")!
    var configuration: PathConfiguration!

    override func setUp() {
        configuration = PathConfiguration()
    }

    func test_initWithNoSourcesSetsDefaultRules() {
        // Default three historical location rules are always added by default.
        XCTAssertEqual(configuration.rules.count, PathRule.defaultServerRoutes.count)

        for rule in PathRule.defaultServerRoutes {
            XCTAssertNotNil(configuration.properties(for: rule.patterns.first!))
        }
    }

    func test_init_automaticallyLoadsTheConfigurationFromTheSpecifiedLocation() {
        loadConfigurationFromFile()

        XCTAssertEqual(configuration.settings.count, 2)
        // Default three historical location rules are always added by default.
        XCTAssertEqual(configuration.rules.count, 5 + PathRule.defaultServerRoutes.count)

        for rule in PathRule.defaultServerRoutes {
            XCTAssertNotNil(configuration.properties(for: rule.patterns.first!))
        }
    }

    func test_settings_returnsCurrentSettings() {
        loadConfigurationFromFile()

        XCTAssertEqual(configuration.settings, [
            "some-feature-enabled": true,
            "server": "beta"
        ])
    }

    func test_propertiesForPath_whenPathMatches_returnsProperties() {
        loadConfigurationFromFile()

        XCTAssertEqual(configuration.properties(for: "/"), [
            "page": "root"
        ])
    }

    func test_propertiesForPath_whenPathMatchesMultipleRules_mergesProperties() {
        loadConfigurationFromFile()

        XCTAssertEqual(configuration.properties(for: "/new"), [
            "context": "modal",
            "background_color": "black"
        ])

        XCTAssertEqual(configuration.properties(for: "/edit"), [
            "context": "modal",
            "background_color": "white"
        ])
    }

    func test_propertiesForURL_withParams() {
        loadConfigurationFromFile()

        let url = URL(string: "http://turbo.test/sample.pdf?open_in_external_browser=true")!

        Hotwire.config.pathConfiguration.matchQueryStrings = false
        XCTAssertEqual(configuration.properties(for: url), [:])

        Hotwire.config.pathConfiguration.matchQueryStrings = true
        XCTAssertEqual(configuration.properties(for: url), [
            "open_in_external_browser": true
        ])
    }

    func test_propertiesForPath_whenNoMatch_returnsEmptyProperties() {
        loadConfigurationFromFile()

        XCTAssertEqual(configuration.properties(for: "/missing"), [:])
    }

    func test_subscript_isAConvenienceMethodForPropertiesForPath() {
        loadConfigurationFromFile()

        XCTAssertEqual(configuration.properties(for: "/new"), configuration["/new"])
        XCTAssertEqual(configuration.properties(for: "/edit"), configuration["/edit"])
        XCTAssertEqual(configuration.properties(for: "/"), configuration["/"])
        XCTAssertEqual(configuration.properties(for: "/missing"), configuration["/missing"])
        XCTAssertEqual(configuration.properties(for: "/sample.pdf?open_in_external_browser=true"), configuration["/sample.pdf?open_in_external_browser=true"])
    }

    func loadConfigurationFromFile() {
        configuration.sources = [.file(fileURL)]
    }
}

class PathConfigTests: XCTestCase {
    func test_json_withValidJSON_decodesSuccessfully() throws {
        let fileURL = Bundle.module.url(forResource: "test-configuration", withExtension: "json", subdirectory: "Fixtures")!

        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let config = try PathConfigurationDecoder(json: json)

        XCTAssertEqual(config.settings.count, 2)
        XCTAssertEqual(config.rules.count, 5)
    }

    func test_json_withMissingRulesKey_failsToDecode() throws {
        XCTAssertThrowsError(try PathConfigurationDecoder(json: [:])) { error in
            XCTAssertEqual(error as? JSONDecodingError, JSONDecodingError.invalidJSON)
        }
    }
}
