import HotwireNative
import UIKit

class LargeTitleNavigationController: HotwireNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
    }
}
