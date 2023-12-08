import Foundation
import Hotwire

extension BridgeComponent {
    static var allTypes: [BridgeComponent.Type] {
        [
            FormComponent.self,
            MenuComponent.self,
            OverflowMenuComponent.self
        ]
    }
}
