import XCTest
import RxSwift
@testable import DataViz

class EventSourceSessionMock: EventSourceSession {
    var state: Observable<EventSourceSessionState> = PublishSubject.never()

    var error: Observable<Error> = PublishSubject.never()

    var data: Observable<String> = PublishSubject.never()

    private(set) var startInvoked = false
    func start() {
        startInvoked = true
    }

    private(set) var stopInvoked = false
    func stop() {
        stopInvoked = true
    }
}

class EventSourceSessionTests: XCTestCase {

    var context: ContextMock!
    var disposeBag: DisposeBag!
    var sut: EventSourceSessionImpl!

    let testUrl = URL(string: "http://test.com")!
    var state: EventSourceSessionState?
    var error: Error?
    var data: String?

    var urlSession: URLSessionMock!
    var urlSessionConstructorInvoked = false
    var urlSessionConstructorConfiguration: URLSessionConfiguration?

    override func setUp() {
        super.setUp()

        disposeBag = DisposeBag()
        context = ContextMock()

        let sessionCunstructor: EventSourceSessionImpl.URLSessionConstructor = { [unowned self] configuration, delegate, queue in
            self.urlSessionConstructorInvoked = true
            self.urlSessionConstructorConfiguration = configuration
            self.urlSession = URLSessionMock(delegate: delegate)
            return self.urlSession
        }
        sut = EventSourceSessionImpl(url: testUrl, urlSessionConstructor: sessionCunstructor)
        sut.state.subscribe(onNext: { [weak self] state in
            self?.state = state
        }).disposed(by: disposeBag)
        sut.error.subscribe(onNext: { [weak self] error in
            self?.error = error
        }).disposed(by: disposeBag)
        sut.data.subscribe(onNext: { [weak self] data in
            self?.data = data
        }).disposed(by: disposeBag)
    }
    
    override func tearDown() {
        state = nil
        error = nil
        data = nil
        sut = nil
        context = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func testClosedStateOnInit() {
        XCTAssertEqual(state, .closed)
    }

    func testConectingStateOnStart() {
        sut.start()
        XCTAssertEqual(state, .connecting)
    }

    func testCreateNewURLSessionOnStart() {
        sut.start()
        XCTAssertTrue(urlSessionConstructorInvoked)
    }

    func testCorrectSessionSetupOnStart() {
        sut.start()
        XCTAssertEqual(urlSession.dataTaskUrl, testUrl)
        XCTAssertEqual(urlSessionConstructorConfiguration?.timeoutIntervalForRequest, TimeInterval(INT_MAX))
        XCTAssertEqual(urlSessionConstructorConfiguration?.timeoutIntervalForResource, TimeInterval(INT_MAX))
    }

    func testStartSessionDataTaskOnStart() {
        sut.start()
        XCTAssertTrue(urlSession.dataTaskInvoked)
        XCTAssertTrue(urlSession.dataTaskMock.resumeInvoked)
    }

    func testNoSecondStartSessionDataTaskOnSecondStart() {
        sut.start()
        urlSession.dataTaskInvoked = false
        urlSession.dataTaskMock.resumeInvoked = false
        sut.start()
        XCTAssertFalse(urlSession.dataTaskInvoked)
        XCTAssertFalse(urlSession.dataTaskMock.resumeInvoked)
    }

    func testClosedStateOnStop() {
        sut.start()
        sut.stop()
        XCTAssertEqual(state, .closed)
    }

    func testInvalidateAndCancelURLSessionRequestOnStop() {
        sut.start()
        sut.stop()
        XCTAssertTrue(urlSession.invalidateAndCancelInvoked)
    }

    func testErrorOnUrlSessionDelegateDidCompleteWithError() {
        sut.start()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: testUrl) as URLSessionTask
        let error = NSError(domain: "com.test", code: 500, userInfo: nil)
        sut.urlSession(session, task: task, didCompleteWithError: error)
        XCTAssertEqual(state, .closed)
        XCTAssertNotNil(self.error)
    }

    func testOpenStateOnUrlSessionDelegateDidResiveResponse() {
        sut.start()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: testUrl) as URLSessionDataTask
        let response = URLResponse()
        sut.urlSession(session, dataTask: task, didReceive: response, completionHandler: { _ in })
        XCTAssertEqual(state, .open)
    }

    func testAllowContinueLoadingOnUrlSessionDelegateDidResiveResponse() {
        sut.start()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: testUrl) as URLSessionDataTask
        let response = URLResponse()
        var responseDisposition: URLSession.ResponseDisposition?
        sut.urlSession(session, dataTask: task, didReceive: response, completionHandler: { disposition in
            responseDisposition = disposition
        })
        XCTAssertEqual(responseDisposition, .allow)
    }

    func testCorrectDataParsingOnUrlSessionDelegateDidResiveData() {
        sut.start()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: testUrl) as URLSessionDataTask
        let response = URLResponse()
        sut.urlSession(session, dataTask: task, didReceive: response, completionHandler: { _ in })
        let valueString = "[{\"name\":\"Pressure\",\"unit\":\"hPa\",\"measurements\":[],\"_id\":\"58c15afe518ca70001b80345\"}]"
        let dataString = "data: \(valueString)\n\n"
        sut.urlSession(session, dataTask: task, didReceive: dataString.data(using: .utf8)!)
        XCTAssertEqual(data, valueString)
    }
}
