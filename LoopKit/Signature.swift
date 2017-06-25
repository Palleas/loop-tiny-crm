import Foundation

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

struct OAuthRequest {
    let consumerKey: String
    let nonce: String
    let timestamp: TimeInterval
    let token: String

    var all: [SignatureItem] {
        return [
            SignatureItem(name: "oauth_consumer_key", value: consumerKey),
            SignatureItem(name: "oauth_nonce", value: nonce),
            SignatureItem(name: "oauth_timestamp", value: String(format: "%.0f", timestamp)),
            SignatureItem(name: "oauth_token", value: token),
            SignatureItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            SignatureItem(name: "oauth_version", value: "1.0"),

        ]
    }


}
