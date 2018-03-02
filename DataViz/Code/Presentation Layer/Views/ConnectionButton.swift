import UIKit
import RxSwift
import RxCocoa

enum ConnectionButtonState {
    case connecting
    case open
    case closed
}

class ConnectionButton: UIButton {
    func set(state: ConnectionButtonState) {
        isEnabled = true
        switch state {
        case .connecting:
            self.setTitle("Connecting...", for: .normal)
            self.setTitleColor(.darkGray, for: .normal)
            isEnabled = false
        case .open:
            self.setTitle("Stop", for: .normal)
            self.setTitleColor(.red, for: .normal)
        case .closed:
            self.setTitle("Start", for: .normal)
            self.setTitleColor(.green, for: .normal)
        }
    }
}

extension Reactive where Base: ConnectionButton {
    var connectionState: Binder<ConnectionButtonState> {
        return Binder(self.base) { button, state in
            button.set(state: state)
        }
    }
}
