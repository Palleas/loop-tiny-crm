import Foundation
import ReactiveSwift

final class TwitterAuthorization {

    struct Token {
        let raw: String
    }

    enum Error: Swift.Error {

    }

    private let consumerKey: String
    private let consumerSecret: String
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let callback: String

    public init(consumerKey: String, consumerSecret: String, clock: ClockProtocol, tokenProvider: TokenProviderProtocol, callback: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.callback = callback
    }

    func requestToken() -> SignalProducer<Token, Error> {
        return .empty
    }

    func createHeader() throws -> String {
        let request = OAuthRequest(
            consumerKey: consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: nil,
            callback: callback
        )

        let signature = try Signature(
            consumerSecret: consumerSecret,
            tokenSecret: nil,
            oauthRequest: request,
            method: .post,
            url: URL(string: "https://api.twitter.com/oauth/request_token")!,
            body: [],
            query: []
        ).sign()

        let header = (request.all + [SignatureItem(name: "oauth_signature", value: signature)])
            .sorted { $0.name < $1.name }
            .map { "\($0.name.addingPercentEncodingForRFC3986()!)=\"\($0.value.addingPercentEncodingForRFC3986()!)\"" } // Remove "!" !
            .joined(separator: ",")

        return "OAuth \(header)"
    }

}
