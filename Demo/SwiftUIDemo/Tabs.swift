import HotwireNative
import UIKit

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
        image: UIImage(systemName: "arrow.left.arrow.right")!,
        url: Demo.current
    )

    static let bridgeComponents = HotwireTab(
        title: "Bridge Components",
        image: {
            if #available(iOS 17.4, *) {
                return UIImage(systemName: "widget.small")!
            } else {
                return UIImage(systemName: "square.grid.2x2")!
            }
        }(),
        url: Demo.current.appendingPathComponent("components")
    )

    static let resources = HotwireTab(
        title: "Resources",
        image: {
            if #available(iOS 17.4, *) {
                return UIImage(systemName: "questionmark.text.page")!
            } else {
                return UIImage(systemName: "book.closed")!
            }
        }(),
        url: Demo.current.appendingPathComponent("resources")
    )

    static let bugsAndFixes = HotwireTab(
        title: "Bugs & Fixes",
        image: UIImage(systemName: "ladybug")!,
        url: Demo.current.appendingPathComponent("bugs")
    )
}
