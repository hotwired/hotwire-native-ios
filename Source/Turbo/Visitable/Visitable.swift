import UIKit
import WebKit

public protocol VisitableDelegate: AnyObject {
    func visitableViewWillAppear(_ visitable: Visitable)
    func visitableViewDidAppear(_ visitable: Visitable)
    func visitableViewWillDisappear(_ visitable: Visitable)
    func visitableViewDidDisappear(_ visitable: Visitable)
    func visitableDidRequestReload(_ visitable: Visitable)
    func visitableDidRequestRefresh(_ visitable: Visitable)
}

public protocol Visitable: AnyObject {
    var visitableViewController: UIViewController { get }
    var visitableDelegate: VisitableDelegate? { get set }
    var visitableView: VisitableView { get }
    var initialVisitableURL: URL { get }
    var currentVisitableURL: URL { get }

    func visitableDidRender()
    func showVisitableActivityIndicator()
    func hideVisitableActivityIndicator()

    func visitableDidActivateWebView(_ webView: WKWebView)
    func visitableWillDeactivateWebView()
    func visitableDidDeactivateWebView()
}

extension Visitable {
    public func reloadVisitable() {
        visitableDelegate?.visitableDidRequestReload(self)
    }

    public func showVisitableActivityIndicator() {
        visitableView.showActivityIndicator()
    }

    public func hideVisitableActivityIndicator() {
        visitableView.hideActivityIndicator()
    }

    public func visitableDidActivateWebView(_ webView: WKWebView) {
        // No-op
    }

    public func visitableDidDeactivateWebView() {
        // No-op
    }

    func activateVisitableWebView(_ webView: WKWebView) {
        visitableView.activateWebView(webView, forVisitable: self)
        // Explicitly designate the web view's scroll view as the tracked content
        // scroll view so behaviour like UINavigationBar.prefersLargeTitles and the
        // iOS 26 tab bar minimize trigger reliably, without depending on UIKit's
        // subview-ordering heuristic. `.all` covers the top (nav bar) and bottom
        // (tab bar) edges.
        if #available(iOS 15.0, *) {
            visitableViewController.setContentScrollView(webView.scrollView, for: .all)
        }
        alignWebViewScrollOffsetToAdjustedTop(webView)
        visitableDidActivateWebView(webView)
    }

    /// The web view attaches after its view controller is already on screen, so
    /// it misses UIKit's automatic initial content-offset adjustment and sits at
    /// contentOffset 0 instead of -adjustedContentInset.top. The navigation bar
    /// then treats the page as scrolled down and renders a large title
    /// (`prefersLargeTitles`) collapsed until the user scrolls to the top.
    /// Align the offset once the pending layout pass has produced the final
    /// adjusted insets, and only when the web view is at its unadjusted top —
    /// a restored scroll position is left untouched.
    private func alignWebViewScrollOffsetToAdjustedTop(_ webView: WKWebView) {
        let scrollView = webView.scrollView
        DispatchQueue.main.async {
            let top = -scrollView.adjustedContentInset.top
            if scrollView.contentOffset.y > top, scrollView.contentOffset.y <= 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: top), animated: false)
            }
        }
    }

    func deactivateVisitableWebView() {
        visitableWillDeactivateWebView()
        if #available(iOS 15.0, *) {
            visitableViewController.setContentScrollView(nil, for: .all)
        }
        visitableView.deactivateWebView()
        visitableDidDeactivateWebView()
    }

    func updateVisitableScreenshot() {
        visitableView.updateScreenshot()
    }

    func showVisitableScreenshot() {
        visitableView.showScreenshot()
    }

    func hideVisitableScreenshot() {
        visitableView.hideScreenshot()
    }

    func clearVisitableScreenshot() {
        visitableView.clearScreenshot()
    }

    func visitableWillRefresh() {
        visitableView.refreshControl.beginRefreshing()
    }

    func visitableDidRefresh() {
        visitableView.refreshControl.endRefreshing()
    }

    func visitableViewDidRequestRefresh() {
        visitableDelegate?.visitableDidRequestRefresh(self)
    }
}

public extension Visitable where Self: UIViewController {
    var visitableViewController: UIViewController {
        self
    }
}
