import Foundation
import SwiftUI

public protocol ErrorPresentableView: View {
    var error: HotwireNativeError { get }
    var handler: ErrorPresenter.Handler? { get }
}
