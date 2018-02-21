import Foundation
import RxSwift

enum EventSourceSessionState {
    case connecting
    case open
    case closed
}

protocol EventSourceSession {
    var state: Observable<EventSourceSessionState> { get }
    var error: Observable<Error> { get }
    var data: Observable<String> { get }
    func start()
    func stop()
}

protocol HasEventSourceSession {
    var eventSource: EventSourceSession { get }
}

/// *Important*
/// The URLSession object keeps a strong reference to the delegate until app exits or explicitly invalidates the session.
/// If you don’t call stop to invalidate URLSession, your app leaks memory until it exits.
class EventSourceSessionImpl: NSObject, EventSourceSession, URLSessionDataDelegate {
    typealias URLSessionConstructor = (URLSessionConfiguration, URLSessionDataDelegate, OperationQueue) -> URLSessionProtocol

    private let stateVariable = Variable(EventSourceSessionState.closed)
    var state: Observable<EventSourceSessionState> { return stateVariable.asObservable() }

    private let errorSubject = PublishSubject<Error>()
    var error: Observable<Error> { return errorSubject.asObservable() }

    private let dataSubject = PublishSubject<String>()
    var data: Observable<String> { return dataSubject.asObservable() }

    private let url: URL
    private let sessionConstructor: URLSessionConstructor
    private let receivedString: NSString?

    private var urlSession: URLSessionProtocol?
    private var task: URLSessionDataTaskProtocol?

    private var operationQueue = OperationQueue()
    private let receivedDataBuffer = NSMutableData()
    private let validNewlineCharacters = ["\n"]

    convenience init(url: URL) {
        self.init(url: url) { (configuration, delegate, queue) -> URLSessionProtocol in
            return URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
        }
    }

    init(url: URL, urlSessionConstructor: @escaping URLSessionConstructor) {
        self.url = url
        self.sessionConstructor = urlSessionConstructor
        self.receivedString = nil

        super.init()
    }

    //Mark: Start

    func start() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        configuration.timeoutIntervalForResource = TimeInterval(INT_MAX)

        self.stateVariable.value = .connecting
        self.urlSession = sessionConstructor(configuration, self, operationQueue)
        self.task = urlSession!.dataTask(with: self.url)

        self.task?.resume()
    }

    //Mark: - Stop

    open func stop() {
        self.stateVariable.value = .closed
        self.urlSession?.invalidateAndCancel()
    }

    fileprivate func receivedMessageToClose(_ httpResponse: HTTPURLResponse?) -> Bool {
        guard let response = httpResponse  else {
            return false
        }

        if response.statusCode == 204 {
            self.stop()
            return true
        }
        return false
    }

    //MARK: - URLSessionDataDelegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.receivedMessageToClose(dataTask.response as? HTTPURLResponse) {
            return
        }

        if self.stateVariable.value != .open {
            return
        }

        self.receivedDataBuffer.append(data)
        let eventStream = extractEventsFromBuffer()
        self.parseEventStream(eventStream)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(URLSession.ResponseDisposition.allow)

        if self.receivedMessageToClose(dataTask.response as? HTTPURLResponse) {
            return
        }

        self.stateVariable.value = .open
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.stateVariable.value = .closed

        if self.receivedMessageToClose(task.response as? HTTPURLResponse) {
            return
        }

        guard let error = error else { return }
        errorSubject.onNext(error)
    }

    //MARK: - Parsing

    private func extractEventsFromBuffer() -> [String] {
        var events = [String]()

        var searchRange = NSRange(location: 0, length: receivedDataBuffer.length)
        while let foundRange = searchEventDelimiter(in: searchRange) {
            if foundRange.location > searchRange.location {
                let chunkLength = foundRange.location - searchRange.location
                let dataChunk = receivedDataBuffer.subdata(with: NSRange(location: searchRange.location,
                                                                         length: chunkLength))

                if let text = String(bytes: dataChunk, encoding: .utf8) {
                    events.append(text)
                }
            }
            searchRange.location = foundRange.location + foundRange.length
            searchRange.length = receivedDataBuffer.length - searchRange.location
        }

        self.receivedDataBuffer.replaceBytes(in: NSRange(location: 0, length: searchRange.location), withBytes: nil, length: 0)
        return events
    }

    private func searchEventDelimiter(in range: NSRange) -> NSRange? {
        let delimiters = validNewlineCharacters.map { "\($0)\($0)".data(using: .utf8)! }

        for delimiter in delimiters {
            let foundRange = receivedDataBuffer.range(of: delimiter,
                                                      options: NSData.SearchOptions(),
                                                      in: range)
            if foundRange.location != NSNotFound {
                return foundRange
            }
        }

        return nil
    }

    private func parseEventStream(_ events: [String]) {
        var parsedData: [String] = Array()

        for event in events {
            if event.isEmpty {
                continue
            }

            if event.hasPrefix(":") {
                continue
            }

            parsedData.append(parseData(event))
        }

        for data in parsedData {
            dataSubject.onNext(data)
        }
    }

    private func parseData(_ eventString: String) -> String {
        for line in eventString.components(separatedBy: CharacterSet.newlines) as [String] {
            let (k, value) = self.parseKeyValuePair(line)
            if let key = k, key == "data" {
                return value ?? ""
            }
        }

        return ""
    }

    private func parseKeyValuePair(_ line: String) -> (String?, String?) {
        var key: NSString?, value: NSString?
        let scanner = Scanner(string: line)
        scanner.scanUpTo(":", into: &key)
        scanner.scanString(":", into: nil)

        for newline in validNewlineCharacters {
            if scanner.scanUpTo(newline, into: &value) {
                break
            }
        }

        return (key as String?, value as String?)
    }
}
