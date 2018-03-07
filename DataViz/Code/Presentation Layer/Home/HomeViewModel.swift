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
        let items = Driver.combineLatest([
                context.persistentStore.temperatureMeasurements,
                context.persistentStore.pressureMeasurements,
                context.persistentStore.voltageMeasurements,
                context.persistentStore.pm1Measurements,
                context.persistentStore.serialMeasurements,
                context.persistentStore.locationMeasurements
            ]) { $0.filter { $0 != nil }
                    .map { $0! }
                    .map {
                        return HomeCellViewModel(dataType: $0)
                }
        }
        measurements = items.throttle(1.5).map { [AnimatableSectionModel(model: "", items: $0)] }

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
