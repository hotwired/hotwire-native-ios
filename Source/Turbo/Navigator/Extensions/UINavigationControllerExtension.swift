import UIKit

extension UINavigationController {
    func replaceLastViewController(with viewController: UIViewController) {
        if Hotwire.config.animateReplaceActions {
            addFadeTransition()
        }

        let viewControllers = viewControllers.dropLast()
        setViewControllers(viewControllers + [viewController], animated: false)
    }

    func setModalPresentationStyle(via proposal: VisitProposal) {
        switch proposal.modalStyle {
        case .medium:
            modalPresentationStyle = .automatic
            if #available(iOS 15.0, *) {
                if let sheet = sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
            }
        case .large:
            modalPresentationStyle = .automatic
        case .full:
            modalPresentationStyle = .fullScreen
        case .pageSheet:
            modalPresentationStyle = .pageSheet
        case .formSheet:
            modalPresentationStyle = .formSheet
        }
    }

    private func addFadeTransition() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = CATransaction.animationDuration()
        view.layer.add(transition, forKey: kCATransition)
    }
}
