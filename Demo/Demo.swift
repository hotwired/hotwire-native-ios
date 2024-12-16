import Foundation

struct Demo {
    static let remote = URL(string: "https://hotwire-native-demo.dev")!
    static let local = URL(string: "http://localhost:45678")!

    /// Update this to choose which demo is run
    static var current: URL {
        remote
    }
}
