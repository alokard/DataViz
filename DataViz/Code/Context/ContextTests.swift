import XCTest
@testable import DataViz

class ContextMock: FlowContext {
    let configurationMock = ConfigurationMock()
    var configuration: Configuration { return configurationMock }

    let errorHandlerMock = ErrorHandlingMock()
    var errorHandler: ErrorHandling { return errorHandlerMock }

    func newQueue() -> OperationQueue {
        return OperationQueue()
    }

    let urlSessionMock = URLSessionMock()
    private(set) var newUrlSessionInvoked = false
    private(set) var newUrlSessionConfiguration: URLSessionConfiguration?
    func newUrlSession(configuration: URLSessionConfiguration, delegate: URLSessionDataDelegate, delegateQueue: OperationQueue) -> URLSessionProtocol {
        newUrlSessionInvoked = true
        newUrlSessionConfiguration = configuration
        return urlSessionMock
    }
}

class ContextTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
