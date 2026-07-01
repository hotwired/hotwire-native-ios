import UIKit

private let routedLocationKey = malloc(1)!

extension UIViewController {
    /// The location the navigator routed this view controller to, stamped at route time by
    /// `NavigationHierarchyController`. Navigation identity checks read this so two instances
    /// of the same custom view-controller class at different URLs are distinguishable.
    var routedLocation: URL? {
        get { objc_getAssociatedObject(self, routedLocationKey) as? URL }
        set { objc_setAssociatedObject(self, routedLocationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
