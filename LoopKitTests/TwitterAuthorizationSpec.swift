import Quick
import Nimble
@testable import LoopKit


class TwitterAuthorizationSpec: QuickSpec {
    override func spec() {
        describe("TwitterAuthorization") {

            let authorization = TwitterAuthorization(
                consumerKey: "cChZNFj6T5R0TigYB9yd1w",
                consumerSecret: "L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg",
                clock: StaticClock(timestamp: 1318467427),
                tokenProvider: StaticTokenProvider(token: "ea9ec8429b68d6b77cd5600adbbb0456"),
                callback: "http://localhost/sign-in-with-twitter/"
            )

            let expected = """
OAuth oauth_callback="http%3A%2F%2Flocalhost%2Fsign-in-with-twitter%2F",oauth_consumer_key="cChZNFj6T5R0TigYB9yd1w",oauth_nonce="ea9ec8429b68d6b77cd5600adbbb0456",oauth_signature="F1Li3tvehgcraF8DMJ7OyxO4w9Y%3D",oauth_signature_method="HMAC-SHA1",oauth_timestamp="1318467427",oauth_version="1.0"
"""

            it("creates an authorization header") {
                expect { try authorization.createHeader() } == expected
            }
        }
    }
}

