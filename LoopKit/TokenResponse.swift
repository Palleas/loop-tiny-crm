import Foundation

public struct TokenResponse: BodyDecodable {
    public let token: String
    public let tokenSecret: String
    public let callbackConfirmed: Bool

    public var authenticate: URL {
        var comps = URLComponents(string: "https://api.twitter.com/oauth/authenticate")
        comps?.queryItems = [URLQueryItem(name: "oauth_token", value: token)]

        return comps!.url!
    }

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

