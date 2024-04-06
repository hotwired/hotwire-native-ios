@testable import HotwireNative
import XCTest

class VisitOptionsTests: XCTestCase {
    func test_Decodable_defaultsToAdvanceActionWhenNotProvided() throws {
        let json = "{}".data(using: .utf8)!

        let options = try JSONDecoder().decode(VisitOptions.self, from: json)
        XCTAssertEqual(options.action, .advance)
        XCTAssertNil(options.response)
    }

    func test_Decodable_usesProvidedActionWhenNotNil() throws {
        let json = """
        {"action": "restore"}
        """.data(using: .utf8)!

        let options = try JSONDecoder().decode(VisitOptions.self, from: json)
        XCTAssertEqual(options.action, .restore)
        XCTAssertNil(options.response)
    }

    func test_Decodable_canBeInitializedWithResponse() throws {
        _ = try validVisitVisitOptions(responseHTMLString: "<html></html>")
    }
}

extension VisitOptionsTests {
    func validVisitVisitOptions(responseHTMLString: String?) throws -> VisitOptions {
        var responseJSON = ""
        if let responseHTMLString {
            responseJSON = ", \"responseHTML\": \"\(responseHTMLString)\""
        }

        let json = """
        {"response": {"statusCode": 200\(responseJSON)}}
        """.data(using: .utf8)!

        let options = try JSONDecoder().decode(VisitOptions.self, from: json)
        XCTAssertEqual(options.action, .advance)

        let response = try XCTUnwrap(options.response)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.responseHTML, responseHTMLString)
        return options
    }
}

extension VisitOptions: Equatable {
    public static func == (lhs: VisitOptions, rhs: VisitOptions) -> Bool {
        lhs.action == rhs.action && lhs.response == rhs.response
    }
}

extension VisitResponse: Equatable {
    public static func == (lhs: VisitResponse, rhs: VisitResponse) -> Bool {
        lhs.responseHTML == rhs.responseHTML && lhs.statusCode == rhs.statusCode
    }
}
