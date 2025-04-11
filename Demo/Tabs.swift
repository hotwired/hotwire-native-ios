import Foundation
import HotwireNative

extension HotwireTab {
    static let all: [HotwireTab] = {
        var tabs: [HotwireTab] = [
            .navigation,
            .bridgeComponents,
            .resources
        ]

        if Demo.current == Demo.local {
            tabs.append(.bugsAndFixes)
        }

        return tabs
    }()

    static let navigation = HotwireTab(
        title: "Navigation",
        image: .init(systemName: "arrow.left.arrow.right")!,
        url: Demo.current
    )

    static let bridgeComponents = HotwireTab(
        title: "Bridge Components",
        image: .init(systemName: "widget.small")!,
        url: Demo.current.appending(path: "components")
    )

    static let resources = HotwireTab(
        title: "Resources",
        image: .init(systemName: "questionmark.text.page")!,
        url: Demo.current.appending(path: "resources")
    )

    static let bugsAndFixes = HotwireTab(
        title: "Bugs & Fixes",
        image: .init(systemName: "ladybug")!,
        url: Demo.current.appending(path: "bugs")
    )
}
