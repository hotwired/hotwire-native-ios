@testable import HotwireNative
import XCTest

class PathConfigurationModalStyleTests: XCTestCase {
    private let fileURL = Bundle.module.url(forResource: "test-modal-styles-configuration", withExtension: "json", subdirectory: "Fixtures")!
    var configuration: PathConfiguration!

    override func setUp() {
        configuration = PathConfiguration(sources: [.file(fileURL)])
        XCTAssertGreaterThan(configuration.rules.count, 0)
    }

    // MARK: -  Modal Styles

    func test_defaultModalStyle() {
        XCTAssertEqual(configuration.properties(for: "/new").modalStyle, .large)
    }

    func test_mediumModalStyle() {
        XCTAssertEqual(configuration.properties(for: "/newMedium").modalStyle, .medium)
    }

    func test_largeModalStyle() {
        XCTAssertEqual(configuration.properties(for: "/newLarge").modalStyle, .large)
    }

    func fullModalStyle() {
        XCTAssertEqual(configuration.properties(for: "/newFull").modalStyle, .full)
    }

    func test_pageSheetModalStyle() {
        XCTAssertEqual(configuration.properties(for: "/newPageSheet").modalStyle, .pageSheet)
    }

    func test_formSheetModalStyle() {
        XCTAssertEqual(configuration.properties(for: "/newFormSheet").modalStyle, .formSheet)
    }

    func test_unknownModalStyle_returnsDefault() {
        XCTAssertEqual(configuration.properties(for: "/unknown").modalStyle, .large)
    }

    // MARK: -  Modal properties

    func test_modalDismissEnabled() {
        XCTAssertEqual(configuration.properties(for: "/new").modalDismissGestureEnabled, false)
    }

    func test_modalDismissDisabled() {
        XCTAssertEqual(configuration.properties(for: "/newMedium").modalDismissGestureEnabled, true)
    }

    func test_modalDismissMissing() {
        XCTAssertEqual(configuration.properties(for: "/newLarge").modalDismissGestureEnabled, true)
    }
}
