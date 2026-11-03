@testable import HotwireNative
import XCTest

final class DialogCompletionTests: XCTestCase {
    func test_complete_callsHandlerWithResult() {
        var results: [Bool] = []
        let completion = DialogCompletion(defaultResult: false) { results.append($0) }

        completion.complete(with: true)

        XCTAssertEqual(results, [true])
    }

    func test_complete_twice_callsHandlerOnce() {
        var results: [Bool] = []
        let completion = DialogCompletion(defaultResult: false) { results.append($0) }

        completion.complete(with: true)
        completion.complete(with: false)

        XCTAssertEqual(results, [true])
    }

    func test_deinit_withoutAnswer_callsHandlerWithDefault() {
        var results: [Bool] = []
        var completion: DialogCompletion<Bool>? = DialogCompletion(defaultResult: false) { results.append($0) }
        XCTAssertNotNil(completion)

        completion = nil

        XCTAssertEqual(results, [false])
    }

    func test_deinit_afterAnswer_doesNotCallHandlerAgain() {
        var results: [Bool] = []
        var completion: DialogCompletion<Bool>? = DialogCompletion(defaultResult: false) { results.append($0) }
        completion?.complete(with: true)

        completion = nil

        XCTAssertEqual(results, [true])
    }
}
