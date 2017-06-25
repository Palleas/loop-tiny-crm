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

final class Twitter {
    private let consumerKey: String
    private let consumerSecret: String
    private let token: String
    private let tokenSecret: String
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let version: String

    init(consumerKey: String, consumerSecret: String, token: String, tokenSecret: String, clock: ClockProtocol, tokenProvider: TokenProviderProtocol, version: String = "1.1") {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.token = token
        self.tokenSecret = tokenSecret
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.version = version
    }

    func prepareRequest() -> OAuthRequest {
        return OAuthRequest(
            consumerKey: consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: token
        )
    }

    /// Sign a request
    ///
    /// - Parameters:
    ///   - request: request to execute and sign
    ///   - provider: token provider that will generate a random token
    ///   - clock: clock that will provide the timestamp
    /// - Returns: a URL Request, signed
    /// https://dev.twitter.com/oauth/overview/creating-signatures
    func sign(_ request: Request, oauthRequest: OAuthRequest) -> String{
        let signatureItems = oauthRequest.all

        let url = createURL(with: request, version: version)

        // Collecting the request method and URL
        var signatureBaseString = request.method.rawValue
        signatureBaseString += "&" + url.absoluteString.addingPercentEncodingForRFC3986()!

        // Collecting the request method and URL
        let allItems = signatureItems
            + request.items.map({ SignatureItem(name: $0.name, value: $0.value ?? "") })
            + request.body.map({ SignatureItem(name: $0.name, value: $0.value ?? "") })

        let sortedItems = allItems.sorted { $0.name < $1.name }

        let parameterString = sortedItems
            .map { "\($0.name.addingPercentEncodingForRFC3986()!)=\($0.value.addingPercentEncodingForRFC3986()!)" }
            .joined(separator: "&")

        // Creating the signature base string
        signatureBaseString += "&\(parameterString.addingPercentEncodingForRFC3986()!)"

        let signingKey = "\(consumerSecret.addingPercentEncodingForRFC3986()!)&\(tokenSecret.addingPercentEncodingForRFC3986()!)"

        return try! HMAC(key: signingKey.data(using: .utf8)!.bytes, variant: .sha1)
            .authenticate(signatureBaseString.data(using: .utf8)!.bytes)
            .toBase64()!
    }
}




