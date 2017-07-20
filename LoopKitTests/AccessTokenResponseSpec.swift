import Quick
import Nimble
@testable import LoopKit

class AccessTokenResponseSpec: QuickSpec {
    override func spec() {
        describe("AccessTokenResponse") {
            it("is decoded based on a URL string") {
                let payload = "oauth_token=7588892-kagSNqWge8gB1WwE3plnFsJHAZVfxWD7Vb57p0b4&oauth_token_secret=PbKfYqSryyeKDWz4ebtY3o5ogNLG11WJuZBc9fQrQo&screen_name=Palleas&x_auth_expires=0"

                let decoder = BodyDecoder()

                var response: AccessTokenResponse?
                expect { response = try decoder.decode(AccessTokenResponse.self, from: payload) }.notTo(throwError())
                expect(response?.token) == "7588892-kagSNqWge8gB1WwE3plnFsJHAZVfxWD7Vb57p0b4"
                expect(response?.tokenSecret) == "PbKfYqSryyeKDWz4ebtY3o5ogNLG11WJuZBc9fQrQo"
                expect(response?.screenName) == "Palleas"
                
            }
        }
    }
}
