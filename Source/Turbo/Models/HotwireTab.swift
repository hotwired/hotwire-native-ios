import Foundation
import UIKit

/// Represents a tab in the `HotwireTabBarController`.
public struct HotwireTab: Identifiable, Hashable {
    public let id: String
    /// The title of the tab.
    public let title: String
    /// The image the tab item uses.
    public let image: UIImage
    ///The image the tab item uses when the user selects it.
    ///If you don’t provide `selectedImage`, the `image` is used for both selection states.
    public let selectedImage: UIImage?
    /// The URL associated with the tab, used for routing.
    public let url: URL

    public let isSearchTab: Bool

    public init(id: String? = nil,
                title: String,
                image: UIImage,
                selectedImage: UIImage? = nil,
                url: URL,
                isSearchTab: Bool = false) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.url = url
        self.isSearchTab = isSearchTab
    }
}
