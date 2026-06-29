import Foundation
import SwiftUI

struct DefaultErrorView: ErrorPresentableView {
    let error: HotwireNativeError
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
        return DefaultErrorView(
            error: .web(WebError(errorCode: 0, message: "Could not connect to the server."))
        ) {}
    }
}
