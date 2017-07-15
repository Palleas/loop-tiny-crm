import Foundation

public struct TokenResponse: BodyDecodable {
    let token: String
    let tokenSecret: String
    let callbackConfirmed: Bool

    init(token: String, tokenSecret: String, callbackConfirmed: Bool) {
        self.token = token
        self.tokenSecret = tokenSecret
        self.callbackConfirmed = callbackConfirmed
    }

    init(decoder: BodyDecoderContainer) throws {
        self.token = try decoder.value(forKey: "oauth_token")
        self.tokenSecret = try decoder.value(forKey: "oauth_token_secret")
        guard let callbackConfirmed = Bool(try decoder.value(forKey: "oauth_callback_confirmed")) else {
            throw BodyDecoderError.invalidFormat
        }
        self.callbackConfirmed = callbackConfirmed

    }
}

extension TokenResponse: AutoEquatable {}
extension TokenResponse: AutoHashable {}

