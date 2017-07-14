import Foundation
import CryptoSwift


enum Method: String {
    case get = "GET"
    case post = "POST"
}

struct Request<Value> {
    let method: Method
    let path: String
    let items: [URLQueryItem]?
    let body: [URLQueryItem]?
}

func createURL<T>(with request: Request<T>, version: String) -> URL {
    var comps = URLComponents(string: "https://api.twitter.com/")!
    comps.path = "/\(version)/\(request.path)"

    if let items = request.items {
        comps.queryItems = items
    }

    return comps.url!
}

struct Credentials {
    let consumerKey: String
    let consumerSecret: String
    let token: String
    let tokenSecret: String
}

final class Twitter {
    private let credentials: Credentials
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let version: String

    init(credentials: Credentials, clock: ClockProtocol, tokenProvider: TokenProviderProtocol, version: String = "1.1") {
        self.credentials = credentials
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.version = version
    }

    func createOAuthRequest() -> OAuthRequest {
        return OAuthRequest(
            consumerKey: credentials.consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: credentials.token,
            callback: nil
        )
    }
}




