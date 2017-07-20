import Foundation
import ReactiveSwift
import Result

final public class TwitterAuthorization {

    public enum Error: Swift.Error {
        case signatureError
        case requestError
        case internalError

        case invalidCompletionURL
    }

    private let consumerKey: String
    private let consumerSecret: String
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let callback: String

    public static let completion = Signal<(token: String, verifier: String), Error>.pipe()

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
                    return Result(error: Error.internalError)
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

    static public func completeAuthorization(with url: URL) -> Result<(token: String, verifier: String), Error> {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("URL \(url) is invalid")
            return .failure(.invalidCompletionURL)
        }

        guard
            let token = comps.queryItems?.first(where: { $0.name == "oauth_token" })?.value,
            let verifier = comps.queryItems?.first(where: { $0.name == "oauth_verifier"})?.value else {
            print("Completion URL doesn't have token and/or verifier")
            return .failure(.invalidCompletionURL)
        }

        return .success((token: token, verifier: verifier))
    }

}

