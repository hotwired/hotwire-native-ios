import Foundation

enum UserAgent {
    static func build(applicationPrefix: String?, componentTypes: [BridgeComponent.Type]) -> String {
        let components = componentTypes.map { $0.name }.joined(separator: " ")
        let componentsSubstring = "bridge-components: [\(components)]"

        return [
            applicationPrefix,
            "Hotwire Native iOS;",
            "Turbo Native iOS;",
            componentsSubstring
        ].compactMap { $0 }.joined(separator: " ")
    }
}
