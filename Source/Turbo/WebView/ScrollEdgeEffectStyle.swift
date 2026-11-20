import UIKit

/// The style of a scroll view's edge effect, for example under the
/// navigation bar. Mirrors `UIScrollEdgeEffect.Style`, which is only
/// available on iOS 26 and later.
public enum ScrollEdgeEffectStyle {
    /// Let the system pick the style.
    case automatic

    /// A soft, blurred edge that blends the bar into the content.
    case soft

    /// A hard edge with a dividing line.
    case hard
}

extension UIScrollView {
    /// Sets the style of the top edge effect on iOS 26 and later.
    /// Does nothing on earlier versions, or when built with an SDK
    /// older than iOS 26.
    func setTopEdgeEffectStyle(_ style: ScrollEdgeEffectStyle) {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            switch style {
            case .automatic: topEdgeEffect.style = .automatic
            case .soft: topEdgeEffect.style = .soft
            case .hard: topEdgeEffect.style = .hard
            }
        }
        #endif
    }
}
