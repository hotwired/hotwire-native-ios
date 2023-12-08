import Hotwire
import UIKit

final class WebViewController: HotwireWebViewController {
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = .systemBackground

        if presentingViewController != nil {
            let action = UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: action)
        }

        bridgeDelegate.onViewDidLoad()
    }
}
