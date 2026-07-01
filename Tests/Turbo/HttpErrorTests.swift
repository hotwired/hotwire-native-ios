import XCTest
@testable import HotwireNative

final class HTTPErrorTests: XCTestCase {

    // MARK: - from(statusCode:) Range Boundaries

    func test_from_statusCode1_returnsNil() {
        XCTAssertNil(HTTPError(statusCode: 1))
    }

    func test_from_statusCode399_returnsNil() {
        XCTAssertNil(HTTPError(statusCode: 399))
    }

    func test_from_statusCode400_isClientError() {
        XCTAssertEqual(HTTPError(statusCode: 400), .client(.badRequest))
    }

    func test_from_statusCode499_isClientError() {
        XCTAssertEqual(HTTPError(statusCode: 499), .client(.other(statusCode: 499)))
    }

    func test_from_statusCode500_isServerError() {
        XCTAssertEqual(HTTPError(statusCode: 500), .server(.internalServerError))
    }

    func test_from_statusCode599_isServerError() {
        XCTAssertEqual(HTTPError(statusCode: 599), .server(.other(statusCode: 599)))
    }

    func test_from_statusCode600_returnsNil() {
        XCTAssertNil(HTTPError(statusCode: 600))
    }

    // MARK: - ClientError Round-Trips

    func test_clientError_badRequest_roundTrips() {
        assertClientErrorRoundTrip(.badRequest, statusCode: 400)
    }

    func test_clientError_unauthorized_roundTrips() {
        assertClientErrorRoundTrip(.unauthorized, statusCode: 401)
    }

    func test_clientError_paymentRequired_roundTrips() {
        assertClientErrorRoundTrip(.paymentRequired, statusCode: 402)
    }

    func test_clientError_forbidden_roundTrips() {
        assertClientErrorRoundTrip(.forbidden, statusCode: 403)
    }

    func test_clientError_notFound_roundTrips() {
        assertClientErrorRoundTrip(.notFound, statusCode: 404)
    }

    func test_clientError_methodNotAllowed_roundTrips() {
        assertClientErrorRoundTrip(.methodNotAllowed, statusCode: 405)
    }

    func test_clientError_notAcceptable_roundTrips() {
        assertClientErrorRoundTrip(.notAcceptable, statusCode: 406)
    }

    func test_clientError_proxyAuthenticationRequired_roundTrips() {
        assertClientErrorRoundTrip(.proxyAuthenticationRequired, statusCode: 407)
    }

    func test_clientError_requestTimeout_roundTrips() {
        assertClientErrorRoundTrip(.requestTimeout, statusCode: 408)
    }

    func test_clientError_conflict_roundTrips() {
        assertClientErrorRoundTrip(.conflict, statusCode: 409)
    }

    func test_clientError_misdirectedRequest_roundTrips() {
        assertClientErrorRoundTrip(.misdirectedRequest, statusCode: 421)
    }

    func test_clientError_unprocessableEntity_roundTrips() {
        assertClientErrorRoundTrip(.unprocessableEntity, statusCode: 422)
    }

    func test_clientError_preconditionRequired_roundTrips() {
        assertClientErrorRoundTrip(.preconditionRequired, statusCode: 428)
    }

    func test_clientError_tooManyRequests_roundTrips() {
        assertClientErrorRoundTrip(.tooManyRequests, statusCode: 429)
    }

    func test_clientError_unmapped418_fallsToOther() {
        assertClientErrorRoundTrip(.other(statusCode: 418), statusCode: 418)
    }

    func test_clientError_unmapped451_fallsToOther() {
        assertClientErrorRoundTrip(.other(statusCode: 451), statusCode: 451)
    }

    // MARK: - ServerError Round-Trips

    func test_serverError_internalServerError_roundTrips() {
        assertServerErrorRoundTrip(.internalServerError, statusCode: 500)
    }

    func test_serverError_notImplemented_roundTrips() {
        assertServerErrorRoundTrip(.notImplemented, statusCode: 501)
    }

    func test_serverError_badGateway_roundTrips() {
        assertServerErrorRoundTrip(.badGateway, statusCode: 502)
    }

    func test_serverError_serviceUnavailable_roundTrips() {
        assertServerErrorRoundTrip(.serviceUnavailable, statusCode: 503)
    }

    func test_serverError_gatewayTimeout_roundTrips() {
        assertServerErrorRoundTrip(.gatewayTimeout, statusCode: 504)
    }

    func test_serverError_httpVersionNotSupported_roundTrips() {
        assertServerErrorRoundTrip(.httpVersionNotSupported, statusCode: 505)
    }

    func test_serverError_unmapped599_fallsToOther() {
        assertServerErrorRoundTrip(.other(statusCode: 599), statusCode: 599)
    }

    // MARK: - HTTPError statusCode Delegation

    func test_statusCode_delegatesToClientError() {
        XCTAssertEqual(HTTPError.client(.notFound).statusCode, 404)
    }

    func test_statusCode_delegatesToServerError() {
        XCTAssertEqual(HTTPError.server(.badGateway).statusCode, 502)
    }

    // MARK: - ClientError Descriptions

    func test_clientError_unauthorized_description() {
        XCTAssertEqual(HTTPError.ClientError.unauthorized.errorDescription, "Unauthorized")
    }

    func test_clientError_notFound_description() {
        XCTAssertEqual(HTTPError.ClientError.notFound.errorDescription, "Not Found")
    }

    func test_clientError_tooManyRequests_description() {
        XCTAssertEqual(HTTPError.ClientError.tooManyRequests.errorDescription, "Too Many Requests")
    }

    func test_clientError_other_description_includesStatusCode() {
        XCTAssertEqual(HTTPError.ClientError.other(statusCode: 418).errorDescription, "Client Error (418)")
    }

    // MARK: - ServerError Descriptions

    func test_serverError_internalServerError_description() {
        XCTAssertEqual(HTTPError.ServerError.internalServerError.errorDescription, "Internal Server Error")
    }

    func test_serverError_serviceUnavailable_description() {
        XCTAssertEqual(HTTPError.ServerError.serviceUnavailable.errorDescription, "Service Unavailable")
    }

    func test_serverError_other_description_includesStatusCode() {
        XCTAssertEqual(HTTPError.ServerError.other(statusCode: 599).errorDescription, "Server Error (599)")
    }

    // MARK: - Helpers

    private func assertClientErrorRoundTrip(
        _ expected: HTTPError.ClientError,
        statusCode: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let created = HTTPError.ClientError(statusCode: statusCode)
        XCTAssertEqual(created, expected, file: file, line: line)
        XCTAssertEqual(created.statusCode, statusCode, "statusCode round-trip failed", file: file, line: line)
    }

    private func assertServerErrorRoundTrip(
        _ expected: HTTPError.ServerError,
        statusCode: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let created = HTTPError.ServerError(statusCode: statusCode)
        XCTAssertEqual(created, expected, file: file, line: line)
        XCTAssertEqual(created.statusCode, statusCode, "statusCode round-trip failed", file: file, line: line)
    }
}
