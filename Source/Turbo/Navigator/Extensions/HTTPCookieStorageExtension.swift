import Foundation

extension HTTPCookieStorage {
    /// Makes the cookies sent to `url` match `cookies`, removing any that are no longer present.
    func replaceCookies(for url: URL, with cookies: [HTTPCookie]) {
        self.cookies(for: url)?.forEach(deleteCookie)
        setCookies(cookies, for: url, mainDocumentURL: url)
    }
}
