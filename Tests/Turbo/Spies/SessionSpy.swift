@testable import HotwireNative

final class SessionSpy: Session {
    var visitWasCalled = false
    var visitAction: VisitAction?

    override func visit(_ visitable: any Visitable, action: VisitAction) {
        visitWasCalled = true
        visitAction = action
        super.visit(visitable, action: action)
    }
}
