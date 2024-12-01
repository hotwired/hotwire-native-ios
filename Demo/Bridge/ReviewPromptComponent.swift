import HotwireNative
import StoreKit

class ReviewPromptComponent: BridgeComponent {
  override class var name: String { "review-prompt" }

  private var viewController: UIViewController? {
    delegate.destination as? UIViewController
  }

  override func onReceive(message: HotwireNative.Message) {
    if let scene = viewController?.view.window?.windowScene {
      SKStoreReviewController.requestReview(in: scene)
    }
  }
}
