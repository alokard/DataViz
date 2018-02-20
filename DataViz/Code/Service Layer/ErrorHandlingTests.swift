import XCTest
import RxSwift
@testable import DataViz

class ErrorHandlingMock: ErrorHandling {
    let errorSubject: PublishSubject<[Error]>? = PublishSubject()

    private(set) var recordErrorInvoked = false
    private(set) var recordedError: Error?
    private(set) var recordedAdditionalInfo: [String : Any]?
    func record(error: Error, additionalInfo: [String : Any]?) {
        recordErrorInvoked = true
        recordedError = error
        recordedAdditionalInfo = additionalInfo
    }
}

class ErrorHandlingTests: XCTestCase {
    
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
