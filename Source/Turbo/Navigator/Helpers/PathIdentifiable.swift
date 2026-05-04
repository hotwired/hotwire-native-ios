import UIKit

/// A view controller may conform to `PathIdentifiable` to expose the URL it represents.
///
/// `Navigator` uses this URL — instead of view-controller type equality — when deciding
/// whether a proposed visit refers to the page already on top of the stack or to the page
/// directly beneath it. Without this conformance, two instances of the same custom view
/// controller class but with different URLs are indistinguishable to the navigator and may
/// be incorrectly popped or replaced.
///
/// `Visitable` inherits from this protocol, so existing visitable view controllers satisfy
/// it automatically via `initialVisitableURL`.
public protocol PathIdentifiable: AnyObject {
    var initialVisitableURL: URL { get }
}
