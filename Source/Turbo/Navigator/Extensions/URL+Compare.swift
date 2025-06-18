import Foundation

extension URL {
    /// Returns a Bool value indicating whether the given URL refers to the same location,
    /// taking into account the specified path properties.
    ///
    /// - Parameters:
    ///   - url: The URL to compare against.
    ///   - pathProperties: The path properties of the given URL.
    /// - Returns: `true` if the current instance and the given URL represent the same location; otherwise, `false`.
    func isSameLocation(as url: URL, pathProperties: PathProperties) -> Bool {
        switch pathProperties.queryStringPresentation {
        case .replace:
            return path == url.path
        case .default:
            return path == url.path && query == url.query
        }
    }
}
