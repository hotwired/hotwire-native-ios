import SwiftUI

public protocol ErrorPresenter: UIViewController {
    typealias Handler = () -> Void

    func presentError(_ error: Error, retryHandler: Handler?)
}

public extension ErrorPresenter {
    /// Presents an error in a full screen view.
    /// The error view will display a `Retry` button if `retryHandler != nil`.
    /// Tapping `Retry` will call `retryHandler?()` then dismiss the error.
    ///
    /// - Parameters:
    ///   - error: presents the data in this error
    ///   - retryHandler: a user-triggered action to perform in case the error is recoverable
    func presentError(_ error: Error, retryHandler: Handler?) {
        let view = Hotwire.config.makeCustomErrorView(error, retryHandler)
        let viewController = ErrorViewController(rootView: view)

        addChild(viewController)
        addFullScreenSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func removeErrorViewController() {
        guard let host = children.first(where: { $0 is ErrorViewController }) else { return }
        host.willMove(toParent: nil)
        host.view.removeFromSuperview()
        host.removeFromParent()
    }
}

extension UIViewController: ErrorPresenter {}

// MARK: Internal

struct DefaultErrorView: View {
    let error: Error
    let handler: ErrorPresenter.Handler?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 38, weight: .semibold))
                .foregroundColor(.accentColor)

            Text("Error loading page")
                .font(.largeTitle)

            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)

            if let handler {
                Button("Retry") {
                    handler()
                }
                .font(.system(size: 17, weight: .bold))
            }
        }
        .padding(32)
    }
}

// MARK: Private

private final class ErrorViewController: UIHostingController<AnyView> {}

private struct DefaultErrorView_Previews: PreviewProvider {
    static var previews: some View {
        return DefaultErrorView(error: NSError(
            domain: "com.example.error",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "Could not connect to the server."]
        )) {}
    }
}

private extension UIViewController {
    func addFullScreenSubview(_ subview: UIView) {
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.topAnchor.constraint(equalTo: view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
