import XCTest
@testable import LoopKit

class SignatureTests: XCTestCase {
    
    func testSignatureIsValidForUpdateStatus() throws {
        let updateStatus = UpdateStatus(
            includeEntities: true,
            status: "Hello Ladies + Gentlemen, a signed OAuth request!"
        )

        let request = OAuthRequest(
            consumerKey: "xvz1evFS4wEEPTGEFPHBog",
            nonce: "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
            timestamp: 1318622958,
            token: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
            callback: nil
        )

        let expected = "tnnArxj06cWHq44gCs1OSKk/jLY="

        let signature = Signature(
            consumerSecret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw",
            tokenSecret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE",
            oauthRequest: request,
            method: updateStatus.method,
            url: createURL(with: updateStatus, version: "1"),
            body: updateStatus.body,
            query: updateStatus.items
        )

        XCTAssertEqual(expected, try signature.sign())
    }

    func testSignatureIsValidForRequestToken() throws {
        let requestToken = RequestToken()

        let request = OAuthRequest(
            consumerKey: "cChZNFj6T5R0TigYB9yd1w",
            nonce: "ea9ec8429b68d6b77cd5600adbbb0456",
            timestamp: 1318467427,
            token: nil,
            callback: "http://localhost/sign-in-with-twitter/"
        )

        let signature = Signature(
            consumerSecret: "L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg",
            tokenSecret: nil,
            oauthRequest: request,
            method: .post,
            url: URL(string: "https://api.twitter.com/oauth/request_token")!,
            body: requestToken.body,
            query: requestToken.items
        )

        let expected = "F1Li3tvehgcraF8DMJ7OyxO4w9Y="

        XCTAssertEqual(expected, try signature.sign())
    }
}
