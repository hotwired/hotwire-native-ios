import Foundation

public enum Strada {
    public static var config: StradaConfig = StradaConfig()
    
    public static func userAgentSubstring(for componentTypes: [BridgeComponent.Type]) -> String {
        let components = componentTypes.map { $0.name }.joined(separator: " ")
        return "bridge-components: [\(components)]"
    }
}
