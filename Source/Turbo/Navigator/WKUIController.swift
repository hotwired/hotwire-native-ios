import Foundation
import WebKit

public protocol WKUIControllerDelegate: AnyObject {
    func present(_ alert: UIAlertController, animated: Bool)
}

open class WKUIController: NSObject, WKUIDelegate {
    private weak var delegate: WKUIControllerDelegate?

    public init(delegate: WKUIControllerDelegate!) {
        self.delegate = delegate
    }

    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard let delegate else {
            completionHandler()
            return
        }
        let completion = DialogCompletion(defaultResult: ()) { completionHandler() }
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default) { _ in
            completion.complete(with: ())
        })
        delegate.present(alert, animated: true)
    }

    open func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard let delegate else {
            completionHandler(false)
            return
        }
        let completion = DialogCompletion(defaultResult: false, completionHandler: completionHandler)
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion.complete(with: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion.complete(with: false)
        })
        delegate.present(alert, animated: true)
    }

    /// Ensures that taps inside an embed that should route out of the iframe are handled.
    open func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.request.url != nil else {
            return nil
        }

        if let targetFrame = navigationAction.targetFrame,
           targetFrame.isMainFrame {
            return nil
        }

        webView.load(navigationAction.request)
        return nil
    }
}

/// Calls a JavaScript dialog's completion handler exactly once: with the user's answer, or
/// with `defaultResult` if the alert goes away unanswered, for example when UIKit tears down
/// the alert because its tab was removed. WebKit raises an exception if the handler is
/// never called.
final class DialogCompletion<Result> {
    private var completionHandler: ((Result) -> Void)?
    private let defaultResult: Result

    init(defaultResult: Result, completionHandler: @escaping (Result) -> Void) {
        self.defaultResult = defaultResult
        self.completionHandler = completionHandler
    }

    func complete(with result: Result) {
        completionHandler?(result)
        completionHandler = nil
    }

    deinit {
        completionHandler?(defaultResult)
    }
}
