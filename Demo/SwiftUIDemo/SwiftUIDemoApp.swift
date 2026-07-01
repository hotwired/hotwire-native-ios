import HotwireNative
import SwiftUI

@main
struct SwiftUIDemoApp: App {
    private let navigatorDelegate = AppNavigatorDelegate()

    init() {
        configureHotwire()
    }

    var body: some Scene {
        WindowGroup {
            HotwireRootView(tabs: HotwireTab.all)
                .navigatorDelegate(navigatorDelegate)
                .ignoresSafeArea()
        }
    }

    private func configureHotwire() {
        // Load path configuration from local file and remote server.
        Hotwire.loadPathConfiguration(from: [
            .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
            .server(Demo.current.appendingPathComponent("configurations/ios_v1.json"))
        ])

        // Set an optional custom user agent prefix.
        Hotwire.config.applicationUserAgentPrefix = "Hotwire SwiftUI Demo;"

        // Register bridge components.
        Hotwire.registerBridgeComponents([
            FormComponent.self,
            MenuComponent.self,
            OverflowMenuComponent.self,
        ])

        // Configure UI options.
        Hotwire.config.backButtonDisplayMode = .minimal
        Hotwire.config.showDoneButtonOnModals = true
        Hotwire.config.animateReplaceActions = true
        #if DEBUG
        Hotwire.config.debugLoggingEnabled = true
        #endif
    }
}
