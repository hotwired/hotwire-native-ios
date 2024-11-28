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
        
        let items:[UIAction] = data.items.map { item in
            UIAction(title: item.title, image: UIImage(systemName: item.image)){ (action) in
                // create a hash/dictionary to send the selector for this item
                // back to the webside
                let data = ["selector": item.selector]
                
                // trigger the callback on 'this.send("connect"...' from the
                // stimulus controller.
                self.reply(to: "connect", with: data)
                //                        ^^^^^^^^^^^
                // this passed the data through to the callback function on the webside
            }
        }
        
        // build the menu item
        let image = UIImage(systemName: data.image)
        let menu = UIMenu(children: items)
        let menu_item = UIBarButtonItem(image: image, menu: menu)
        
        if data.side == "right" {
            viewController.navigationItem.rightBarButtonItem = menu_item
        } else {
            viewController.navigationItem.leftBarButtonItem = menu_item
        }
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
        let url: String        // not really used...discard at some point
        let selector: String   // important!  used to signal which menu item was selected
    }

}
