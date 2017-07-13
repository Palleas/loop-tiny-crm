import Foundation
import CryptoSwift


enum Method: String {
    case get = "GET"
    case post = "POST"
}

protocol Request {
    var method: Method { get }
    var path: String { get }
    var items: [URLQueryItem] { get }
    var body: [URLQueryItem] { get }
}

func createURL(with request: Request, version: String) -> URL {
    var comps = URLComponents(string: "https://api.twitter.com/")!
    comps.path = "/\(version)/\(request.path)"

    if !request.items.isEmpty {
        comps.queryItems = request.items
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
            token: credentials.token
        )
    }
}




