import Quick
import Nimble
@testable import BirdNest

class TokenResponseSpec: QuickSpec {
    override func spec() {
        describe("TokenResponse") {
            let response = TokenResponse(
                token: "NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0",
                tokenSecret: "token-secret",
                callbackConfirmed: true
            )

            it("has the URL to authenticate the user with") {
                expect(response.authenticate) == URL(string: "https://api.twitter.com/oauth/authenticate?oauth_token=NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0")!
            }
        }
    }
}
