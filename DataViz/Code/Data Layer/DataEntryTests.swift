import XCTest
@testable import DataViz

class DataEntryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseCorrectlyWithValidJson() throws {
        let json = DataEntry<Any>.json
        let sut = try DataEntry<Any>(json: json)
        XCTAssertEqual(sut.name, "Pressure")
        XCTAssertEqual(sut.unit, "hPa")
        XCTAssertEqual(sut.measurements?.count, 3)
    }

    func testThrowOnInvalidJson() {
        XCTAssertThrowsError(try DataEntry<Any>(json: [:]))
    }
}

extension DataEntry {
    static var json: JSON {
        return [
            "name": "Pressure",
            "unit": "hPa",
            "measurements": [
                [
                    1519210837,
                    1019.8993272725085
                ],
                [
                    1519210838,
                    1013.0518839435697
                ],
                [
                    1519210839,
                    1088.37668791775
                ]
            ],
            "_id": "5a8d515721f2b20001022e63"
        ]
    }
}
