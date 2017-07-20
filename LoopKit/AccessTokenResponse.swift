import Foundation

public struct AccessTokenResponse: BodyDecodable {

    let token: String
    let tokenSecret: String
    let screenName: String

    init(decoder: BodyDecoderContainer) throws {
        self.token = try decoder.value(forKey: "oauth_token")
        self.tokenSecret = try decoder.value(forKey: "oauth_token_secret")
        self.screenName = try decoder.value(forKey: "screen_name")
    }
}

