import UIKit

extension UIViewController {
    static func from(storyboard: Storyboard, identifier id: String? = nil) -> Self {
        let identifier = id ?? String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
