import Foundation
import ReactiveSwift
import Result


public protocol TwitterAuthorizationType {

    func requestAccessToken(token: String, verifier: String) -> SignalProducer<AccessTokenResponse, TwitterAuthorizationError>

    func requestToken() -> SignalProducer<TokenResponse, TwitterAuthorizationError>

    static func extractRequestTokenAndVerifier(from url: URL) -> Result<(token: String, verifier: String), TwitterAuthorizationError>
}

public enum TwitterAuthorizationError: Swift.Error {
    case signatureError
    case requestError
    case internalError

    case invalidCompletionURL
}

final public class TwitterAuthorization: TwitterAuthorizationType {


    private let consumerKey: String
    private let consumerSecret: String
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let callback: String

    public static let completion = Signal<(token: String, verifier: String), TwitterAuthorizationError>.pipe()

    public init(consumerKey: String, consumerSecret: String, clock: ClockProtocol = Clock(), tokenProvider: TokenProviderProtocol = TokenProvider(), callback: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.callback = callback
    }

    public func requestToken() -> SignalProducer<TokenResponse, TwitterAuthorizationError> {
        return SignalProducer(result: createRequest(path: "oauth/request_token"))
            .mapError { _ in TwitterAuthorizationError.signatureError }
            .flatMap(.latest) { request in
                return URLSession.shared.reactive.data(with: request).mapError { _ in TwitterAuthorizationError.requestError }
            }
            .attemptMap { arg -> Result<TokenResponse, TwitterAuthorizationError> in
                let (data, response) = arg

                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    return Result(error: TwitterAuthorizationError.internalError)
                }

                return Result {
                    let decoder = BodyDecoder()
                    return try decoder.decode(TokenResponse.self, from: String(data: data, encoding: .utf8)!)
                }
            }
    }

    public func requestAccessToken(token: String, verifier: String) -> SignalProducer<AccessTokenResponse, TwitterAuthorizationError> {
        return SignalProducer(result: createRequest(path: "oauth/access_token", token: token, verifier: verifier))
            .mapError { _ in TwitterAuthorizationError.signatureError }
            .flatMap(.latest) { request in
                return URLSession.shared.reactive.data(with: request).mapError { _ in TwitterAuthorizationError.requestError }
        }
        .attemptMap { arg -> Result<AccessTokenResponse, TwitterAuthorizationError> in
            let (data, response) = arg

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return Result(error: TwitterAuthorizationError.internalError)
            }

            return Result {
                let decoder = BodyDecoder()
                return try decoder.decode(AccessTokenResponse.self, from: String(data: data, encoding: .utf8)!)
            }
        }
    }

    func createRequest(path: String, token: String? = nil, verifier: String? = nil) -> Result<URLRequest, Signature.Error> {

        let body: Data?
        if let verifier = verifier {
            body = "oauth_verifier=\(verifier)".data(using: .utf8)!
        } else {
            body = nil
        }

        return Result {
            var request = URLRequest(url: URL(string: "https://api.twitter.com/\(path)")!)
            request.allHTTPHeaderFields = ["Authorization": try createHeader(token: token, callback: self.callback)]
            request.httpMethod = Method.post.rawValue
            request.httpBody = body
            return request
        }
    }

    func createHeader(token: String?, callback: String?) throws -> String {
        let request = OAuthRequest(
            consumerKey: consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: token,
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

    static public func extractRequestTokenAndVerifier(from url: URL) -> Result<(token: String, verifier: String), TwitterAuthorizationError> {
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

