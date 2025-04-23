import HotwireNative
import UIKit

/// A simple native table view controller to demonstrate loading non-Turbo screens
/// for a visit proposal
final class NumbersViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "numbers" }

    init(url: URL, navigator: NavigationHandler) {
        self.url = url
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var url: URL
    private weak var navigator: NavigationHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Numbers"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let number = indexPath.row + 1
        cell.textLabel?.text = "Row \(number)"
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailURL = url.appendingPathComponent("\(indexPath.row + 1)")
        navigator?.route(detailURL)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
