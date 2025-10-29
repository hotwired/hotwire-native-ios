import Foundation
import UIKit

extension HotwireTab {
    func makeTabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
    }
}
