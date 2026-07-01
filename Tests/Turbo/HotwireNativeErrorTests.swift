import XCTest
@testable import HotwireNative

final class HotwireNativeErrorTests: XCTestCase {

    // MARK: - Turbo.js SystemStatusCode Mapping

    func test_turboJSStatusCode_0_createsWebError_networkFailure() {
        let error = HotwireNativeError(turboJSStatusCode: 0)
        XCTAssertEqual(error, .web(WebError(turboError: .networkFailure)))
    }

    func test_turboJSStatusCode_negative1_createsWebError_timeout() {
        let error = HotwireNativeError(turboJSStatusCode: -1)
        XCTAssertEqual(error, .web(WebError(turboError: .timeout)))
    }

    func test_turboJSStatusCode_negative1_webError_isTimeout() {
        let error = HotwireNativeError(turboJSStatusCode: -1)
        if case .web(let webError) = error {
            XCTAssertTrue(webError.isTimeout)
        } else {
            XCTFail("Expected .web, got \(error)")
        }
    }

    func test_turboJSStatusCode_negative2_createsContentTypeMismatchLoadError() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: -2), .load(.contentTypeMismatch))
    }

    // MARK: - HTTP Status Code Mapping

    func test_turboJSStatusCode_401_mapsToUnauthorized() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 401), .http(.client(.unauthorized)))
    }

    func test_turboJSStatusCode_403_mapsToForbidden() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 403), .http(.client(.forbidden)))
    }

    func test_turboJSStatusCode_404_mapsToNotFound() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 404), .http(.client(.notFound)))
    }

    func test_turboJSStatusCode_422_mapsToUnprocessableEntity() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 422), .http(.client(.unprocessableEntity)))
    }

    func test_turboJSStatusCode_429_mapsToTooManyRequests() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 429), .http(.client(.tooManyRequests)))
    }

    func test_turboJSStatusCode_500_mapsToInternalServerError() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 500), .http(.server(.internalServerError)))
    }

    func test_turboJSStatusCode_502_mapsToBadGateway() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 502), .http(.server(.badGateway)))
    }

    func test_turboJSStatusCode_503_mapsToServiceUnavailable() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 503), .http(.server(.serviceUnavailable)))
    }

    // MARK: - Unknown 4xx/5xx -> .other

    func test_turboJSStatusCode_410_mapsToClientOther() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 410), .http(.client(.other(statusCode: 410))))
    }

    func test_turboJSStatusCode_418_mapsToClientOther() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 418), .http(.client(.other(statusCode: 418))))
    }

    func test_turboJSStatusCode_451_mapsToClientOther() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 451), .http(.client(.other(statusCode: 451))))
    }

    func test_turboJSStatusCode_506_mapsToServerOther() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 506), .http(.server(.other(statusCode: 506))))
    }

    func test_turboJSStatusCode_520_mapsToServerOther() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 520), .http(.server(.other(statusCode: 520))))
    }

    // MARK: - Unexpected Negative Codes -> .web

    func test_turboJSStatusCode_negative3_createsWebError() {
        let error = HotwireNativeError(turboJSStatusCode: -3)
        XCTAssertEqual(error, .web(WebError(turboError: .unknownStatusCode(-3))))
    }

    // MARK: - Unexpected Positive Non-HTTP Codes -> .web fallback

    func test_turboJSStatusCode_1_mapsToWebError() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 1), .web(WebError(errorCode: 1, message: "Unexpected status code")))
    }

    func test_turboJSStatusCode_100_mapsToWebError() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 100), .web(WebError(errorCode: 100, message: "Unexpected status code")))
    }

    func test_turboJSStatusCode_301_mapsToWebError() {
        XCTAssertEqual(HotwireNativeError(turboJSStatusCode: 301), .web(WebError(errorCode: 301, message: "Unexpected status code")))
    }

    // MARK: - statusCode

    func test_statusCode_returnsCode_forClientHttpError() {
        XCTAssertEqual(HotwireNativeError.http(.client(.unauthorized)).statusCode, 401)
    }

    func test_statusCode_returnsCode_forServerHttpError() {
        XCTAssertEqual(HotwireNativeError.http(.server(.badGateway)).statusCode, 502)
    }

    func test_statusCode_returnsNil_forWebError() {
        XCTAssertNil(HotwireNativeError.web(WebError(errorCode: 0, message: nil)).statusCode)
    }

    func test_statusCode_returnsNil_forLoadError() {
        XCTAssertNil(HotwireNativeError.load(.notPresent).statusCode)
    }

    // MARK: - urlError

    func test_urlError_returnsURLError_forWebErrorWithURLError() {
        let urlError = URLError(.notConnectedToInternet)
        let error = HotwireNativeError.web(WebError(urlError: urlError))
        XCTAssertEqual(error.urlError, urlError)
    }

    func test_urlError_returnsNil_forWebErrorWithoutURLError() {
        let error = HotwireNativeError.web(WebError(errorCode: 0, message: nil))
        XCTAssertNil(error.urlError)
    }

    func test_urlError_returnsNil_forHttpError() {
        XCTAssertNil(HotwireNativeError.http(.client(.notFound)).urlError)
    }

    func test_urlError_returnsNil_forLoadError() {
        XCTAssertNil(HotwireNativeError.load(.notPresent).urlError)
    }

    // MARK: - errorDescription

    func test_errorDescription_forHttpError() {
        XCTAssertEqual(HotwireNativeError.http(.client(.notFound)).errorDescription, "Not Found")
    }

    func test_errorDescription_forWebError() {
        let error = HotwireNativeError.web(WebError(urlError: URLError(.notConnectedToInternet)))
        XCTAssertEqual(error.errorDescription, "Could not connect to the server.")
    }

    func test_errorDescription_forLoadError() {
        XCTAssertEqual(
            HotwireNativeError.load(.contentTypeMismatch).errorDescription,
            "The server returned an invalid content type."
        )
    }
}
