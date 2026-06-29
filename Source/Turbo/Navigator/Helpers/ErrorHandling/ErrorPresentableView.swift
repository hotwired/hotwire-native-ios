import Foundation
import SwiftUI

public protocol ErrorPresentableView: View {
    var error: Error { get }
    var handler: ErrorPresenter.Handler? { get }
}
