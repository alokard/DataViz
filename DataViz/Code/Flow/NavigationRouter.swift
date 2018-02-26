import UIKit

protocol NavigationRouter: class {
    var viewControllers: [UIViewController] { get }

    var rootViewController: UIViewController? { get }
    func pushViewController(_ viewController: UIViewController, animated: Bool)

    @discardableResult func popViewController(animated: Bool) -> UIViewController?
    @discardableResult func popToRootViewController(animated: Bool) -> [UIViewController]?
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

extension UINavigationController: NavigationRouter {
    var rootViewController: UIViewController? {
        return viewControllers.first
    }
}
