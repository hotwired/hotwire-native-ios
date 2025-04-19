import Foundation
import WebKit
import XCTest
@testable import HotwireNative

@MainActor
class BridgeDelegateDestinationTests: XCTestCase {
    private var delegate: BridgeDelegate!
    private var destination: AppBridgeDestination!
    private var bridge: BridgeSpy!

    override func setUp() {
        destination = AppBridgeDestination()
        delegate = BridgeDelegate(location: "https://37signals.com",
                                  destination: destination,
                                  componentTypes: [BridgeComponentSpy.self])

        bridge = BridgeSpy()
        delegate.bridge = bridge
    }

    // NOTE: viewDidLoad() is always called as the first view lifecycle method.
    // However, in some cases, such as in a tab bar controller, the view might not trigger `viewDidLoad()`,
    // yet it will still receive calls to `webViewDidBecomeActive(_)` and `webViewDidBecomeDeactivated()`.
    func testBridgeDestinationIsActiveAfterViewDidLoad() {
        delegate.onViewDidLoad()
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
    }

    func testBridgeDestinationIsActiveAfterViewWillAppear() {
        delegate.onViewDidLoad()
        delegate.onViewWillAppear()
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
    }

    func testBridgeDestinationIsActiveAfterViewDidAppear() {
        delegate.onViewDidLoad()
        delegate.onViewDidAppear()
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
    }

    func testBridgeDestinationIsActiveAfterViewWillDisappear() {
        delegate.onViewDidLoad()
        delegate.onViewWillDisappear()
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
    }

    func testBridgeDestinationIsInactiveAfterViewDidDisappear() {
        delegate.onViewDidLoad()
        delegate.onViewDidDisappear()
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNil(component)
    }

    func testBridgeDestinationIsActiveAfterWebViewDidBecomeActive() {
        delegate.webViewDidBecomeActive(WKWebView())
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNotNil(component)
    }

    func testBridgeDestinationIsInactiveAfterWebViewBecomesDeactivated() {
        delegate.webViewDidBecomeDeactivated()
        delegate.bridgeDidReceiveMessage(.test)

        let component: BridgeComponentSpy? = delegate.component()
        XCTAssertNil(component)
    }

    func testBridgeDestinationIsNotifiedWhenComponentIsInitialized() {
        delegate.onViewDidLoad()
        delegate.bridgeDidReceiveMessage(.test)

        XCTAssertTrue(destination.onBridgeComponentInitializedWasCalled)
        XCTAssertTrue(destination.initializedBridgeComponent is BridgeComponentSpy)

        destination.onBridgeComponentInitializedWasCalled = false
        destination.initializedBridgeComponent = nil

        delegate.bridgeDidReceiveMessage(.test)

        XCTAssertFalse(destination.onBridgeComponentInitializedWasCalled)
        XCTAssertNil(destination.initializedBridgeComponent)
    }
}
