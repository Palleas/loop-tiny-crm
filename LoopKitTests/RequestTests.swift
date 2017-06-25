import XCTest
@testable import LoopKit

class RequestTests: XCTestCase {

    func testItCreatesAnURL() {
        let updateStatus = UpdateStatus(
            includeEntities: true,
            status: "Hello Ladies + Gentlemen, a signed OAuth request!"
        )

        let expected = URL(string: "https://api.twitter.com/1.1/statuses/update.json")
        XCTAssertEqual(expected, createURL(with: updateStatus, version: "1.1"))

        let expected2 = URL(string: "https://api.twitter.com/1/statuses/update.json")
        XCTAssertEqual(expected2, createURL(with: updateStatus, version: "1"))
    }
}
