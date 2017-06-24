import XCTest
@testable import LoopKit

class TwitterTests: XCTestCase {

    func testAuthorizationHeaderGeneration() {
        let now: TimeInterval = 1318622958    

        let expected = """
        OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog", oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", oauth_signature="tnnArxj06cWHq44gCs1OSKk%2FjLY%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="\(now)", oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyzMZeS9weJAEb", oauth_version="1.0"
        """

        let updateStatus = UpdateStatus(
            includeEntities: true,
            status: "Hello Ladies + Gentlemen, a signed OAuth request!"
        )

        let t = Twitter(
            consumerKey: "xvz1evFS4wEEPTGEFPHBog",
            consumerSecret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw",
            accessToken: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
            tokenSecret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
        )

        let provider = StaticTokenProvider(token: "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg")
        XCTAssertEqual(expected, t.sign(updateStatus, provider: provider, clock: StaticClock(timestamp: now)).allHTTPHeaderFields?["Authorization"])
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


