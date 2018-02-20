import Foundation

typealias FlowContext = HasConfiguration & HasErrorHandler & QueueProducer & URLSessionProducer

struct Context: FlowContext {
    var configuration: Configuration

    let config: Configuration
    let errorHandler: ErrorHandling

    func newQueue() -> OperationQueue {
        return OperationQueue()
    }

    func newUrlSession(configuration: URLSessionConfiguration,
                       delegate: URLSessionDataDelegate,
                       delegateQueue: OperationQueue) -> URLSessionProtocol {
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }
}

protocol QueueProducer {
    func newQueue() -> OperationQueue
}
