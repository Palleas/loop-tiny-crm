import Foundation

struct SignatureItem {
    let name: String
    let value: String

    static let version = SignatureItem(name: "oauth_version", value: "1.0")
    
    static let signatureMethod = SignatureItem(name: "oauth_signature_method", value: "HMAC-SHA1")
}
