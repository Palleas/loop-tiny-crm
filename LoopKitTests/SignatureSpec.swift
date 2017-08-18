// swiftlint:disable function_body_length
import XCTest
import Quick
import Nimble
@testable import LoopKit

class SignatureSpec: QuickSpec {

    override func spec() {
        describe("Signature") {
            it("generated a valid signature to update a status") {
                let updateStatus = Status.update(
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
                    body: updateStatus.body ?? [],
                    query: updateStatus.items ?? []
                )

                expect { try signature.sign() } == expected
            }

            it("generates a valid signature to request a token") {
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
                    body: [],
                    query: []
                )

                let expected = "F1Li3tvehgcraF8DMJ7OyxO4w9Y="

                expect { try signature.sign() } == expected
            }

            it("generates a valid signature to exchange the request token for an access token") {
                let request = OAuthRequest(
                    consumerKey: "cChZNFj6T5R0TigYB9yd1w",
                    nonce: "a9900fe68e2573b27a37f10fbad6a755",
                    timestamp: 1318467427,
                    token: "NPcudxy0yU5T3tBzho7iCotZ3cnetKwcTIRlX0iwRl0",
                    callback: nil
                )

                let signature = Signature(
                    consumerSecret: "L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg",
                    tokenSecret: nil,
                    oauthRequest: request,
                    method: .post,
                    url: URL(string: "https://api.twitter.com/oauth/access_token")!,
                    body: [URLQueryItem(name: "oauth_verifier", value: "uw7NjWHT6OJ1MpJOXsHfNxoAhPKpgI8BlYDhxEjIBY")],
                    query: []
                )

                let expected = "eLn5QjdCqHdlBEvOogMeGuRxW4k="

                expect { try signature.sign() } == expected
            }
        }
    }
}
