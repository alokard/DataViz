import Foundation

typealias FlowContext = HasConfiguration & HasErrorHandler & HasEventSourceSession

class Context: FlowContext {
    let configuration: Configuration
    let errorHandler: ErrorHandling
    let eventSource: EventSourceSession

    deinit {
        eventSource.stop()
    }

    init(configuration: Configuration, errorHandler: ErrorHandling, eventSource: EventSourceSession) {
        self.configuration = configuration
        self.errorHandler = errorHandler
        self.eventSource = eventSource
    }
}

