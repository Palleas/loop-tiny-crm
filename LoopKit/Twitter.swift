import Foundation
import CryptoSwift
import ReactiveSwift
import Result

public enum Method: String {
    case get = "GET"
    case post = "POST"
}

public struct Request<Value> {
    let method: Method
    let path: String
    let items: [URLQueryItem]?
    let body: [URLQueryItem]?
}

func createURL<T>(with request: Request<T>, version: String) -> URL {
    var comps = URLComponents(string: "https://api.twitter.com")!
    comps.path = "/\(version)/\(request.path)"

    if let items = request.items {
        comps.queryItems = items
    }

    return comps.url!
}

public struct Credentials {
    let consumerKey: String
    let consumerSecret: String
    let token: String
    let tokenSecret: String

    public init(consumerKey: String, consumerSecret: String, token: String, tokenSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.token = token
        self.tokenSecret = tokenSecret
    }

}

public final class Twitter {
    private let credentials: Credentials
    private let clock: ClockProtocol
    private let tokenProvider: TokenProviderProtocol
    private let version: String

    public enum Error: Swift.Error {
        case requestError(Int, Any?)
        case internalError(AnyError?)
        case JSONError(AnyError)
        case notFound
    }

    public init(credentials: Credentials, clock: ClockProtocol, tokenProvider: TokenProviderProtocol, version: String = "1.1") {
        self.credentials = credentials
        self.clock = clock
        self.tokenProvider = tokenProvider
        self.version = version
    }

    func createOAuthRequest() -> OAuthRequest {
        return OAuthRequest(
            consumerKey: credentials.consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: credentials.token,
            callback: nil
        )
    }

    public func execute<T: Decodable>(_ request: Request<T>) -> SignalProducer<T, Error> {
        let requestResult = Result<URLRequest, Error> { () -> URLRequest in
            var r = URLRequest(request: request)
            r.allHTTPHeaderFields = ["Authorization": try createHeader(with: request)]

            return r
        }

        return SignalProducer(result: requestResult)
            .flatMap(.latest, { request in
                return URLSession.shared.reactive.data(with: request)
                    .mapError { Error.internalError($0) }
                    .attemptMap({ (data, response) -> Result<T, Error> in
                        guard let httpResponse = response as? HTTPURLResponse else {
                            return .failure(.internalError(nil))
                        }

                        if httpResponse.statusCode == 404 {
                            return .failure(.notFound)
                        } else if httpResponse.statusCode < 200 || httpResponse.statusCode >= 400 {
                            let errorMessage = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            return .failure(.requestError(httpResponse.statusCode, errorMessage))
                        }

                        return Result(attempt: {
                            let decoder = JSONDecoder()
                            return try decoder.decode(T.self, from: data)
                        })
                        .mapError { Error.JSONError($0) }
                    })
        })
    }

    func createHeader<T>(with request: Request<T>) throws -> String {
        let oauth = OAuthRequest(
            consumerKey: credentials.consumerKey,
            nonce: tokenProvider.generate(),
            timestamp: clock.now(),
            token: credentials.token,
            callback: nil
        )

        let signature = try Signature(
            consumerSecret: credentials.consumerSecret,
            tokenSecret: credentials.tokenSecret,
            oauthRequest: oauth,
            method: request.method,
            url: createURL(with: request, version: "1.1"),
            body: request.body ?? [],
            query: request.items ?? []
        ).sign()

        let header = (oauth.all + [SignatureItem(name: "oauth_signature", value: signature)])
            .sorted { $0.name < $1.name }
            .map { "\($0.name.addingPercentEncodingForRFC3986()!)=\"\($0.value.addingPercentEncodingForRFC3986()!)\"" } // Remove "!" !
            .joined(separator: ",")

        return "OAuth \(header)"
    }

}

extension URLRequest {
    init<T>(request: Request<T>) {
        let url = createURL(with: request, version: "1.1")
        self.init(url: url)

        if let body = request.body {
            self.httpBody = body
                .map { "\($0.name)=\($0.value ?? "")" }
                .joined(separator: "&")
                .data(using: .utf8)
        }
    }
}
