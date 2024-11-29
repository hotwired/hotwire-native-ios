import HotwireNative
import UIKit


final class NavComponent: BridgeComponent {
    override class var name: String { "nav" }

    override func onReceive(message: Message) {
        guard let viewController else { return }
        addButton(via: message, to: viewController)
    }

    private var viewController: UIViewController? {
        delegate.destination as? UIViewController
    }

    private func addButton(via message: Message, to viewController: UIViewController) {
        guard let data: MessageData = message.data() else { return }

        let items: [UIAction] = data.items.map { item in

            UIAction(title: item.title,
                     image: UIImage(systemName: item.image),
                     attributes: item.destructive ? .destructive : [],
                     state: item.state == "on" ? .on : .off
            ) { (_) in
                self.onItemSelected(item: item)
            }
        }

        // build the menu item
        let image = UIImage(systemName: data.image)
        let menu = UIMenu(title: data.title, children: items)
        let menuItem = UIBarButtonItem(image: image, menu: menu)

        if data.side == "right" {
            viewController.navigationItem.rightBarButtonItem = menuItem
        } else {
            viewController.navigationItem.leftBarButtonItem = menuItem
        }
    }

    private func onItemSelected(item: MenuItem) {
        self.reply(
            to: "connect",
            with: SelectionMessageData(selectedIndex: item.index)
        )
    }
}

private extension NavComponent {
    struct MessageData: Decodable {
        let items: [MenuItem]
        let image: String
        let side: String
        let title: String
    }
    struct MenuItem: Decodable {
        let title: String
        let image: String
        let destructive: Bool
        let state: String
        let index: Int
    }
    struct SelectionMessageData: Encodable {
        let selectedIndex: Int
    }
}
