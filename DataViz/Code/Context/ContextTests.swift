import XCTest
@testable import DataViz

class ContextMock: FlowContext {
    let eventSourceMock = EventSourceSessionMock()
    var eventSource: EventSourceSession { return eventSourceMock }

    let configurationMock = ConfigurationMock()
    var configuration: Configuration { return configurationMock }

    let errorHandlerMock = ErrorHandlingMock()
    var errorHandler: ErrorHandling { return errorHandlerMock }

    let persistentStoreMock = PersistentStoreServiceMock()
    var persistentStore: PersistentStoreService { return persistentStoreMock }
}

class ContextTests: XCTestCase {
    var eventSource: EventSourceSessionMock!
    var sut: Context!

    override func setUp() {
        super.setUp()
        eventSource = EventSourceSessionMock()
        sut = Context(configuration: ConfigurationMock(),
                      errorHandler: ErrorHandlingMock(),
                      eventSource: eventSource,
                      persistentStore: PersistentStoreServiceMock())
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testNoMemoryRetainCyclesWithEventSourceOnDeinit() {
        sut = nil
        XCTAssertTrue(eventSource.stopInvoked)
    }
}
