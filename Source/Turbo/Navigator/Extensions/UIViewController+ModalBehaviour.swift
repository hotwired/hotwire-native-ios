import UIKit

extension UIViewController {
    func configureModalBehaviour(with proposal: VisitProposal) {
        isModalInPresentation = !proposal.modalDismissGestureEnabled
    }
}
