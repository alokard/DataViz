import Foundation

typealias FlowContext = HasConfiguration & HasErrorHandler & HasEventSourceSession & HasCoreData

class Context: FlowContext {
    let configuration: Configuration
    let errorHandler: ErrorHandling
    let eventSource: EventSourceSession
    let coreDataService: CoreDataService

    deinit {
        eventSource.stop()
    }

    init(configuration: Configuration,
         errorHandler: ErrorHandling,
         eventSource: EventSourceSession,
         coreDataService: CoreDataService) {
        self.configuration = configuration
        self.errorHandler = errorHandler
        self.eventSource = eventSource
        self.coreDataService = coreDataService
    }
}

