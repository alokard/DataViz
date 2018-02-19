import UIKit

enum Storyboard: String {
    case main = "Main"
}

extension Storyboard {
    func instantiateViewController<T>(withIdentifier id: String) -> T {
        let storyboard = UIStoryboard(name: rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id) as! T
    }

    func instantiateInitialViewController() -> UIViewController? {
        let storyboard = UIStoryboard(name: rawValue, bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
}
