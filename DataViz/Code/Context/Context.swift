import Foundation

typealias FlowContext = HasConfiguration & HasErrorHandler & HasEventSourceSession & HasPersistentStore

class Context: FlowContext {
    let configuration: Configuration
    let errorHandler: ErrorHandling
    let eventSource: EventSourceSession
    let persistentStore: PersistentStoreService

    deinit {
        eventSource.stop()
    }

    init(configuration: Configuration,
         errorHandler: ErrorHandling,
         eventSource: EventSourceSession,
         persistentStore: PersistentStoreService) {
        self.configuration = configuration
        self.errorHandler = errorHandler
        self.eventSource = eventSource
        self.persistentStore = persistentStore
    }
}

