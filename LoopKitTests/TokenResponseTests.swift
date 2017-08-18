import XCTest
@testable import LoopKit

class TokenResponseTests: XCTestCase {

    func testBodyResponseDecoding() throws {
        let body = """
oauth_token=NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0&oauth_token_secret=veNRnAWe6inFuo8o2u8SLLZLjolYDmDP7SzL0YfYI&oauth_callback_confirmed=true
"""
        let expected = TokenResponse(
            token: "NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0",
            tokenSecret: "veNRnAWe6inFuo8o2u8SLLZLjolYDmDP7SzL0YfYI",
            callbackConfirmed: true
        )

        let decoder = BodyDecoder()
        let result = try decoder.decode(TokenResponse.self, from: body)

        XCTAssertEqual(expected, result)
    }
}
