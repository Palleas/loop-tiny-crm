import XCTest
@testable import LoopKit

class SignatureTests: XCTestCase {
    
    func testSignatureIsValid() throws {
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
}
