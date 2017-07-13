import Foundation
import CryptoSwift

struct SignatureItem {
    let name: String
    let value: String

}

extension SignatureItem: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue ^ value.hashValue
    }

    static public func ==(lhs: SignatureItem, rhs: SignatureItem) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}

struct Signature {

    enum Error: Swift.Error {
        case invalidBaseString
        case invalidSigningKey
        case invalidSignature
    }

    let consumerSecret: String
    let tokenSecret: String?
    let oauthRequest: OAuthRequest
    let method: Method
    let url: URL
    let body: [URLQueryItem]
    let query: [URLQueryItem]

    func sign() throws -> String {
        let signatureItems = oauthRequest.all

        // Collecting the request method and URL
        var signatureBaseString = method.rawValue
        signatureBaseString += "&" + url.absoluteString.addingPercentEncodingForRFC3986()!

        // Collecting the request method and URL
        let allItems = signatureItems
            + query.map({ SignatureItem(name: $0.name, value: $0.value ?? "") })
            + body.map({ SignatureItem(name: $0.name, value: $0.value ?? "") })

        let sortedItems = allItems.sorted { $0.name < $1.name }

        let parameterString = sortedItems
            .map { "\($0.name.addingPercentEncodingForRFC3986()!)=\($0.value.addingPercentEncodingForRFC3986()!)" }
            .joined(separator: "&")

        // Creating the signature base string
        signatureBaseString += "&\(parameterString.addingPercentEncodingForRFC3986()!)"

        var signingKey = "\(consumerSecret.addingPercentEncodingForRFC3986()!)&"
        if let tokenSecret = tokenSecret?.addingPercentEncodingForRFC3986() {
            signingKey += tokenSecret
        }

        guard let signatureData = signatureBaseString.data(using: .utf8)?.bytes else {
            throw Error.invalidBaseString
        }

        guard let signingKeyData = signingKey.data(using: .utf8)?.bytes else {
            throw Error.invalidSigningKey
        }

        let cryptoThingie = HMAC(key: signingKeyData, variant: .sha1)
        guard let signature = try cryptoThingie.authenticate(signatureData).toBase64() else {
            throw Error.invalidSignature
        }

        return signature
    }
}

struct OAuthRequest {
    let consumerKey: String
    let nonce: String
    let timestamp: TimeInterval
    let token: String?
    let callback: String?

    var all: [SignatureItem] {
        var allItems = [
            SignatureItem(name: "oauth_consumer_key", value: consumerKey),
            SignatureItem(name: "oauth_nonce", value: nonce),
            SignatureItem(name: "oauth_timestamp", value: String(format: "%.0f", timestamp)),
            SignatureItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            SignatureItem(name: "oauth_version", value: "1.0"),
        ]

        if let token = token {
            allItems.append(SignatureItem(name: "oauth_token", value: token))
        }

        if let callback = callback {
            allItems.append(SignatureItem(name: "oauth_callback", value: callback))
        }

        return allItems.sorted(by: { $0.name < $1.name })
    }

}

final class OAuthRequestCreator {

    private let consumerKey: String
    private let clock: ClockProtocol
    private let tokenProvider: TokenProvider
    private let callback: String
    
    init(consumerKey: String, clock: ClockProtocol, tokenProvider: TokenProvider, callback: String) {
        self.consumerKey = consumerKey
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.callback = callback
    }

    func generate() -> OAuthRequest {
        return OAuthRequest(
            consumerKey: consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: nil,
            callback: nil
        )
    }

}
