import Foundation

class RestorationState {
    var identifier: String?
    var scrollPosition: CGPoint?

    init(identifier: String? = nil, scrollPosition: CGPoint? = nil) {
        self.identifier = identifier
        self.scrollPosition = scrollPosition
    }
}
