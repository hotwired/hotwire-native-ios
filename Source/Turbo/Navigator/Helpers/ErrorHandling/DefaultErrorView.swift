import Foundation
import SwiftUI

struct DefaultErrorView: ErrorPresentableView {
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

private struct DefaultErrorView_Previews: PreviewProvider {
    static var previews: some View {
        return DefaultErrorView(error: NSError(
            domain: "com.example.error",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "Could not connect to the server."]
        )) {}
    }
}
