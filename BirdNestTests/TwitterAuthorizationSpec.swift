import Quick
import Nimble
import OHHTTPStubs
@testable import BirdNest

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

            afterEach {
                OHHTTPStubs.removeAllStubs()
            }

            it("creates an authorization header") {
                // swiftlint:disable line_length
                let expected = """
OAuth oauth_callback="http%3A%2F%2Flocalhost%2Fsign-in-with-twitter%2F",oauth_consumer_key="cChZNFj6T5R0TigYB9yd1w",oauth_nonce="ea9ec8429b68d6b77cd5600adbbb0456",oauth_signature="F1Li3tvehgcraF8DMJ7OyxO4w9Y%3D",oauth_signature_method="HMAC-SHA1",oauth_timestamp="1318467427",oauth_version="1.0"
"""
                // swiftlint:enable line_length

                expect { try authorization.createHeader(token: nil, callback: "http://localhost/sign-in-with-twitter/") } == expected
            }

            it("fetches an authorization token") {
                stub(condition: isAbsoluteURLString("https://api.twitter.com/oauth/request_token"), response: { _ in
                    // swiftlint:disable line_length
                    let response =  "oauth_token=NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0&oauth_token_secret=veNRnAWe6inFuo8o2u8SLLZLjolYDmDP7SzL0YfYI&oauth_callback_confirmed=true"
                    // swiftlint:enable line_length

                    return OHHTTPStubsResponse(data: response.data(using: .utf8)!, statusCode: 200, headers: [:])
                })

                let expected = TokenResponse(
                    token: "NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0",
                    tokenSecret: "veNRnAWe6inFuo8o2u8SLLZLjolYDmDP7SzL0YfYI",
                    callbackConfirmed: true
                )

                expect(authorization.requestToken().first()?.value).toEventually(equal(expected))
            }

            it("receives an error when something isn't HTTP 200") {
                stub(condition: isAbsoluteURLString("https://api.twitter.com/oauth/request_token"), response: { _ in
                    return OHHTTPStubsResponse(data: "<h1>INTERNAL SERVER ERROR OMG</h1>".data(using: .utf8)!, statusCode: 500, headers: [:])
                })

                expect(authorization.requestToken().first()?.error).toEventually(equal(.internalError))
            }

            it("receives an error when something isn't HTTP 200") {
                stub(condition: isAbsoluteURLString("https://api.twitter.com/oauth/request_token"), response: { _ in
                    return OHHTTPStubsResponse(data: "<h1>YOU'RE BEING REDIRECTED, SHOO!</h1>".data(using: .utf8)!, statusCode: 301, headers: [:])
                })

                expect(authorization.requestToken().first()?.error).toEventually(equal(.internalError))
            }

        }
    }
}
