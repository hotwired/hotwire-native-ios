import Foundation

public extension Navigator {
    struct Configuration {
        public let name: String
        public let startLocation: URL

        public init(name: String, startLocation: URL) {
            self.name = name
            self.startLocation = startLocation
        }
    }
}
