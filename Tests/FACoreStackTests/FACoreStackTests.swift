import XCTest
@testable import FACoreStack

final class FACoreStackTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FACoreStack().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
