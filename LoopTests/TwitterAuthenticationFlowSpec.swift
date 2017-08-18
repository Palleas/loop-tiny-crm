import ReactiveSwift
import Quick
import Nimble
@testable import Loop
import LoopKit

class TwitterAuthenticationFlowSpec: QuickSpec {
    override func spec() {
        describe("TwitterAuthenticationFlow") {
            context("without credentials in the keychain") {
                it("sends an error when there is no credentials") {

                }

                it("falls back to fetching credentials from the backend") {

                }
            }

            it("saves in keychain") {
                let auth = StaticTwitterAuthorization()
                let keychain = StaticKeychain()
            }

            it("requests a token") {

            }

            it("exhanges a request token for an access token") {

            }
        }
    }
}

final class StaticTwitterAuthorization: TwitterAuthorizationType {

    func requestToken() -> SignalProducer<TokenResponse, TwitterAuthorizationError> {
        return .empty
    }

    func requestAccessToken(token: String, verifier: String) -> SignalProducer<AccessTokenResponse, TwitterAuthorizationError> {
        return .empty
    }

    static func extractRequestTokenAndVerifier(from url: URL) -> Result<(token: String, verifier: String), TwitterAuthorizationError> {
        return
    }
}

final class StaticSigningRequest: SigninRequestType {

    enum Value {
        case url(URL)
        case error(TwitterAuthenticationFlowError)
    }

    private let value: Value

    init(value: Value) {
        self.value = value
    }

    func perform(with url: URL) -> SignalProducer<URL, TwitterAuthenticationFlowError> {
        switch value {
        case let .error(error):
            return SignalProducer(error: error)
        case let .url(url):
            return SignalProducer(value: url)
        }
    }
}

final class StaticKeychain: KeychainType {
    private var value: String?

    init(value: String? = nil) {
        self.value = value
    }

    func get(_ key: String) -> String? {
        return value
    }

    func set(_ value: String, forKey _: String) -> Bool {
        self.value = value
        return true
    }
}
