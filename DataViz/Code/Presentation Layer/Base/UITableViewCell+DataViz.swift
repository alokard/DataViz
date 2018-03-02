import UIKit

extension UITableViewCell {
    static func dequeueFrom(tableView: UITableView, for indexPath: IndexPath, identifier id: String? = nil) -> Self {
        let identifier = id ?? String(describing: self)
        return tableView.dequeueCustomCell(withIdentifier: identifier, for: indexPath)
    }
}

extension UITableView {
    fileprivate func dequeueCustomCell<T>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}
