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
        let persistentStore = PersistentStoreServiceImpl(dataInput: eventSource.data, coreDataService: coreDataService)
        let errorHandler = SimpleErrorHandler()
        context = Context(configuration: configuration,
                          errorHandler: errorHandler,
                          eventSource: eventSource,
                          persistentStore: persistentStore)

//        eventSource.start()
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
