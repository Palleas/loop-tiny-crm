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

func createURL(with request: Request) -> URL {
    let url = URL(string: "https://api.twitter.com/1/\(request.path)")!
    var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!

    if !request.items.isEmpty {
        comps.queryItems = request.items
    }

    return comps.url!
}

final class Twitter {
    private let consumerKey: String
    private let consumerSecret: String
    private let accessToken: String
    private let tokenSecret: String

    init(consumerKey: String, consumerSecret: String, accessToken: String, tokenSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.accessToken = accessToken
        self.tokenSecret = tokenSecret
    }


    /// Sign a request
    ///
    /// - Parameters:
    ///   - request: request to execute and sign
    ///   - provider: token provider that will generate a random token
    ///   - clock: clock that will provide the timestamp
    /// - Returns: a URL Request, signed
    /// https://dev.twitter.com/oauth/overview/creating-signatures
    func sign(_ request: Request, provider: TokenProviderProtocol, clock: ClockProtocol) -> URLRequest {
        let signatureItems = [
            SignatureItem(name: "oauth_consumer_key", value: consumerKey),
            SignatureItem(name: "oauth_nonce", value: provider.generate()),
            SignatureItem.signatureMethod,
            SignatureItem(name: "oauth_timestamp", value: String(format: "%.0f", clock.now())),
            SignatureItem(name: "oauth_token", value: accessToken),
            SignatureItem.version
        ]

        let url = createURL(with: request)

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

        let hash = try! HMAC(key: signingKey.data(using: .utf8)!.bytes, variant: .sha1)
            .authenticate(signatureBaseString.data(using: .utf8)!.bytes)
            .toBase64()

        // Build the Authorization header


        return URLRequest(url: url)
    }
}




