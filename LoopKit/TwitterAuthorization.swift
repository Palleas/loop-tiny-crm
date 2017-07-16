import Foundation
import ReactiveSwift
import Result

final public class TwitterAuthorization {

    public enum Error: Swift.Error {
        case signatureError
        case requestError
        case serverError(URLResponse)
    }

    private let consumerKey: String
    private let consumerSecret: String
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let callback: String

    public init(consumerKey: String, consumerSecret: String, clock: ClockProtocol = Clock(), tokenProvider: TokenProviderProtocol = TokenProvider(), callback: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.callback = callback
    }

    public func requestToken() -> SignalProducer<TokenResponse, Error> {
        return SignalProducer(result: createRequest())
            .mapError { _ in Error.signatureError }
            .flatMap(.latest) { request in
                return URLSession.shared.reactive.data(with: request).mapError { _ in Error.requestError }
            }
            .attemptMap { arg -> Result<TokenResponse, Error> in
                let (data, response) = arg

                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    return Result(error: Error.serverError(response))
                }

                return Result {
                    let decoder = BodyDecoder()
                    return try decoder.decode(TokenResponse.self, from: String(data: data, encoding: .utf8)!)
                }
            }
    }

    func createRequest() -> Result<URLRequest, Signature.Error> {
        return Result {
            var request = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
            request.allHTTPHeaderFields = ["Authorization": try createHeader()]
            request.httpMethod = Method.post.rawValue

            return request
        }
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
