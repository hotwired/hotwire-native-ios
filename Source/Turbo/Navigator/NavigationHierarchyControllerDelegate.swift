import SafariServices
import WebKit

protocol NavigationHierarchyControllerDelegate: AnyObject {
    
    /// Once the navigation hierarchy is modified, begin a visit on a navigation controller.
    ///
    /// - Parameters:
    ///   - _: the Visitable destination
    ///   - on: the navigation controller that was modified
    ///   - with: the visit options
    func visit(_ : Visitable,
               on: NavigationStackType,
               with: VisitOptions)
    
    /// A refresh will pop (or dismiss) then ask the session to refresh the previous (or underlying) Visitable.
    ///
    /// - Parameters:
    ///   - navigationStack: the stack where the refresh is happening
    ///   - newTopmostVisitable: the visitable to be refreshed
    func refreshVisitable(navigationStack: NavigationStackType,
                          newTopmostVisitable: Visitable)
}
