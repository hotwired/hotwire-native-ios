import Foundation

extension URL {
    /// A computed property that returns the URL's path, ensuring a trailing slash is preserved if it exists.
    ///
    /// This property addresses the behavioral difference between `URL.path` in iOS 15 (which strips trailing slashes)
    /// and `URL.path()` in iOS 16+ (which preserves them), providing a single, consistent behavior across all OS versions.
    var pathPreservingSlash: String {
        if #available(iOS 16.0, *) {
            return path()
        } else {
            return URLComponents(string: absoluteString)?.path ?? ""
        }
    }
}
