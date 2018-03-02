import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol HomeViewModel: ErrorHandling {
    typealias Input = Void
    typealias CreateHandler = (Input) -> HomeViewModel

    var measurements: Driver<[AnimatableSectionModel<String, HomeCellViewModel>]> { get }
    var startButtonState: Driver<ConnectionButtonState> { get }

    func startPressed()
    func showDetails()
}

class HomeViewModelImpl: HomeViewModel {
    typealias Context = HasEventSourceSession & HasPersistentStore

    struct HandlersContainer {
        let showDetails: (DataType) -> Void
    }
    private let context: Context
    private let handlers: HandlersContainer

    let errorSubject: PublishSubject<[Error]>? = PublishSubject()
    let measurements: Driver<[AnimatableSectionModel<String, HomeCellViewModel>]>
    let startButtonState: Driver<ConnectionButtonState>

    required init(context: Context, input: HomeViewModel.Input, data: Void?, handlers: HandlersContainer) {
        self.context = context
        self.handlers = handlers
        let tmpSection = AnimatableSectionModel(model: "", items: [HomeCellViewModel(identity: "Temperature"), HomeCellViewModel(identity: "Presure")])
        measurements = Driver.just([tmpSection])

        startButtonState = context.eventSource.state.map { state in
            switch state {
            case .connecting: return ConnectionButtonState.connecting
            case .open: return ConnectionButtonState.open
            case .closed: return ConnectionButtonState.closed
            }
        }.asDriver(onErrorJustReturn: ConnectionButtonState.closed)
    }

    func startPressed() {
        if context.eventSource.inProgress {
            context.eventSource.stop()
        } else {
            context.eventSource.start()
        }
    }

    func showDetails() {
        //TODO: handle details
        handlers.showDetails(.unknown)
    }
}

extension HomeViewModelImpl: ViewModel { }
