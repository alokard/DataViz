import Foundation
import CoreData
import RxSwift

class ApplicationController: ErrorHandling {
    private let context: Context
    private let navigationRouter: NavigationRouter
    private let disposeBag = DisposeBag()

    init(navigation: NavigationRouter) {
        navigationRouter = navigation

        let configuration = ConfigurationImpl(environment: AppEnvironment())
        let url = configuration.apiUrl!
        let eventSource = EventSourceSessionImpl(url: url)
        let coreDataService = CoreDataServiceImpl()
        let errorHandler = SimpleErrorHandler()
        context = Context(configuration: configuration,
                          errorHandler: errorHandler,
                          eventSource: eventSource,
                          coreDataService: coreDataService)

        eventSource.data.map { jsonString -> [DataEntry<Double>] in
                var result = [DataEntry<Double>]()
                guard let data = jsonString.data(using: .utf8) else { return result }
                guard let jsons = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [JSON] else { return result }
                for json in jsons {
                    guard let temperature = try? DataEntry<Double>(json: json) else { continue }
                    if temperature.name == "Temperature" {
                        result.append(temperature)
                    }
                }
                return result
            }.flatMap { entries -> Observable<DataEntry<Double>> in
                return Observable.from(entries)
            }
            .flatMap { (entry: DataEntry<Double>) -> Observable<(TimeInterval, Double)> in
                guard let measurements = entry.measurements else { return Observable.never() }
                return Observable.from(measurements)
            }
            .subscribe(onNext: { [weak coreDataService] temperatureTouple in
                guard let context = coreDataService?.backgroundContext else { return }

                let object = NSEntityDescription.insertNewObject(forEntityName: "Temperature", into: context) as! Temperature

                object.measurementDate = Date(timeIntervalSince1970: temperatureTouple.0)
                object.value = temperatureTouple.1
                do {
                    try context.save()
                } catch { }
            })
            .disposed(by: disposeBag)

        eventSource.start()
    }

    func setupWithLaunchOptions(_ launchOptions: [AnyHashable: Any]?) {
        let mainFlow = FlowsFactoryImpl(context: context).createMainFlow(navigation: navigationRouter)
        mainFlow.start()
    }

    func didBecomeActive() {

    }

    func willResignActive() {

    }
}
