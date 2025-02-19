import Foundation

struct Tab {
    let title: String
    let imageName: String
    let path: String?

    var url: URL {
        if let path {
            return Demo.current.appending(path: path)
        }
        return Demo.current
    }

    static let all = [
        Tab(title: "Navigation", imageName: "arrow.left.arrow.right", path: nil),
        Tab(title: "Bridge Components", imageName: "widget.small", path: "components"),
        Tab(title: "Resources", imageName: "questionmark.text.page", path: "resources"),
    ]
}
