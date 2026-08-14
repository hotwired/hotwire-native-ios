import HotwireNative
import SwiftUI

/// A simple native view to demonstrate loading non-Turbo screens
/// for a visit proposal.
struct NumbersView: View, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "numbers" }

    let url: URL
    var navigator: NavigationHandler?

    var body: some View {
        List(1...100, id: \.self) { number in
            Button {
                let detailURL = url.appendingPathComponent("\(number)")
                navigator?.route(detailURL)
            } label: {
                HStack {
                    Text("Row \(number)")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Numbers")
    }
}

#Preview {
    NumbersView(url: URL(string: "https://example.com")!)
}
