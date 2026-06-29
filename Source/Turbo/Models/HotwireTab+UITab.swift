import Foundation
import UIKit

extension HotwireTab {
    @available(iOS 18.0, *)
    func makeTab(_ viewController: UIViewController) -> UITab {
        if isSearchTab {
            return UISearchTab(
                title: title,
                image: image,
                identifier: id
            ) { _ in
                viewController
            }
        }

        return UITab(
            title: title,
            image: image,
            identifier: id
        ) { _ in
            viewController
        }
    }
}
