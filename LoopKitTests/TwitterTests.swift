import XCTest
@testable import LoopKit

class TwitterTests: XCTestCase {
    let now: TimeInterval = 1318622958

    // This client is configured to use version "1", not "1.1"
    // I'm fairly confident you're not supposed to call this API anymore
    // but I based my tests on the official request-signing documentation
    let client = Twitter(
        consumerKey: "xvz1evFS4wEEPTGEFPHBog",
        consumerSecret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw",
        token: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
        tokenSecret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE",
        clock: StaticClock(timestamp: 1318622958),
        tokenProvider: StaticTokenProvider(token: "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"),
        version: "1"
    )

    func testAuthorizationHeaderGeneration() {
        let updateStatus = UpdateStatus(
            includeEntities: true,
            status: "Hello Ladies + Gentlemen, a signed OAuth request!"
        )

        let request = OAuthRequest(
            consumerKey: "xvz1evFS4wEEPTGEFPHBog",
            nonce: "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
            timestamp: 1318622958,
            token: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"
        )

        let expected = "tnnArxj06cWHq44gCs1OSKk/jLY="
        XCTAssertEqual(client.sign(updateStatus, oauthRequest: request), expected)
    }

    func testRequestIsPrepared() {
        let prepared = client.prepareRequest()

        let expected = [
            SignatureItem(name: "oauth_consumer_key", value: "xvz1evFS4wEEPTGEFPHBog"),
            SignatureItem(name: "oauth_nonce", value: "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"),
            SignatureItem(name: "oauth_timestamp", value: "1318622958"),
            SignatureItem(name: "oauth_token", value: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"),
            SignatureItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            SignatureItem(name: "oauth_version", value: "1.0")
        ]

        XCTAssertEqual(prepared.all, expected)
    }
}

struct StaticClock: ClockProtocol {
    let timestamp: TimeInterval

    func now() -> TimeInterval {
        return timestamp
    }
}

struct StaticTokenProvider: TokenProviderProtocol {
    let token: String

    func generate() -> String {
        return token
    }
}

