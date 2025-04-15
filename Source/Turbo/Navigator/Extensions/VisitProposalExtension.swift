import UIKit

public extension VisitProposal {
    var context: Navigation.Context {
        properties.context
    }

    var presentation: Navigation.Presentation {
        properties.presentation
    }

    var modalStyle: Navigation.ModalStyle {
        properties.modalStyle
    }

    var pullToRefreshEnabled: Bool {
        properties.pullToRefreshEnabled
    }

    var modalDismissGestureEnabled: Bool {
        properties.modalDismissGestureEnabled
    }

    var viewController: String {
        properties.viewController
    }

    var animated: Bool {
        properties.animated
    }

    internal var isHistoricalLocation: Bool {
        properties.historicalLocation
    }
}
