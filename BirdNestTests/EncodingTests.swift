import XCTest
@testable import BirdNest

class EncodingTests: XCTestCase {

    func testStringsAreProperlyEncoded() {
        // Strings provided by Twitter
        // https://dev.twitter.com/oauth/overview/percent-encoding-parameters
        let provided: [(raw: String, expected: String)] = [
            (raw: "Ladies + Gentlemen", expected: "Ladies%20%2B%20Gentlemen"),
            (raw: "An encoded string!", expected: "An%20encoded%20string%21"),
            (raw: "Dogs, Cats & Mice", expected: "Dogs%2C%20Cats%20%26%20Mice"),
            (raw: "☃", expected: "%E2%98%83")
        ]

        provided.forEach { data in
            XCTAssertEqual(data.raw.addingPercentEncodingForRFC3986(), data.expected)
        }
    }
}
