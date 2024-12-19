import WebKit

public struct WebNavigationDecision: Equatable {
    public let policy: WKNavigationActionPolicy
    public let externallyOpenableURL: URL?
    public let shouldReloadPage: Bool

    public init(policy: WKNavigationActionPolicy,
                externallyOpenableURL: URL? = nil,
                shouldReloadPage: Bool) {
        self.policy = policy
        self.externallyOpenableURL = externallyOpenableURL
        self.shouldReloadPage = shouldReloadPage
    }
}
