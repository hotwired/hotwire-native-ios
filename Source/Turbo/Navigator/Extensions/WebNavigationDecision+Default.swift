import Foundation
import WebKit

extension WebNavigationDecision {
    static func defaultDecision(for navigationAction: WKNavigationAction) -> WebNavigationDecision {
        let isMainFrameNavigation = navigationAction.targetFrame?.isMainFrame ?? false
        let navigationType = navigationAction.navigationType

        // Determine the policy
        let policy: WKNavigationActionPolicy = navigationType == .linkActivated || isMainFrameNavigation ? .cancel : .allow

        // Determine whether to open externally
        let shouldOpenURLExternally = navigationType == .linkActivated || (isMainFrameNavigation && navigationType == .other)

        // Determine whether to reload the page
        let shouldReloadPage = isMainFrameNavigation && navigationType == .reload

        // Determine the externally openable URL
        let externallyOpenableURL: URL? = {
            guard shouldOpenURLExternally, let url = navigationAction.request.url else {
                return nil
            }
            return url
        }()

        return WebNavigationDecision(
            policy: policy,
            externallyOpenableURL: externallyOpenableURL,
            shouldReloadPage: shouldReloadPage
        )
    }
}
