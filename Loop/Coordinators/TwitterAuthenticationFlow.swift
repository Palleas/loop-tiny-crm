import Foundation
import ReactiveSwift
import LoopKit
import SafariServices
import Result
import KeychainSwift

protocol Keychain {
    var token: String? { get }
    var tokenSecret: String? { get }
}

enum TwitterAuthenticationFlowError: Swift.Error {
    case authorizationError(TwitterAuthorizationError)
    case internalError
    case keychainError(OSStatus)
    case noCredentialsInKeychain
}

final class TwitterAuthenticationFlow {
    enum State {
        case notStarted
        case checkingKeychain
        case requestingToken
        case requestingSignIn
        case exhangingRequestToken
        case savingInKeychain
    }

    private let auth: TwitterAuthorizationType
    private let signinRequest: SigninRequestType
    private let keychain: KeychainType

    let state = MutableProperty<State>(.notStarted)

    init(auth: TwitterAuthorizationType, signinRequest: SigninRequestType, keychain: KeychainType) {
        self.auth = auth
        self.signinRequest = signinRequest
        self.keychain = keychain
    }

    func perform() -> SignalProducer<(token: String, secret: String), TwitterAuthenticationFlowError> {
        return self.loadFromKeychain()
            .flatMapError { _ in
                self.requestToken()
                    .flatMap(.latest, self.requestSignIn)
                    .flatMap(.latest, self.exchangeRequestToken)
                    .attempt(self.saveInKeychain)
            }
    }

    func loadFromKeychain() -> SignalProducer<(token: String, secret: String), TwitterAuthenticationFlowError> {
        return SignalProducer { sink, _ in
            let keychain = KeychainSwift()
            guard
                let token = keychain.get(Keys.Twitter.oauthAccessToken),
                let tokenSecret = keychain.get(Keys.Twitter.oauthAccessTokenSecret) else {
                    sink.send(error: .noCredentialsInKeychain)
                    return
            }

            sink.send(value: (token: token, secret: tokenSecret))
        }
        .on(starting: { [weak self] in self?.state.swap(.checkingKeychain) })

    }

    func saveInKeychain(token: String, secret: String) -> Result<(), TwitterAuthenticationFlowError> {
        let keychain = KeychainSwift()
        guard keychain.set(token, forKey: Keys.Twitter.oauthAccessToken) else {
            return .failure(.keychainError(keychain.lastResultCode))
        }

        guard keychain.set(secret, forKey: Keys.Twitter.oauthAccessTokenSecret) else {
            return .failure(.keychainError(keychain.lastResultCode))
        }

        return .success(())
    }

    func requestToken() -> SignalProducer<URL, TwitterAuthenticationFlowError> {
        return auth.requestToken()
            .mapError { .authorizationError($0) }
            .map { $0.authenticate }
            .on(starting: { [weak self] in self?.state.swap(.requestingToken) })

    }

    func requestSignIn(with url: URL) -> SignalProducer<(token: String, verifier: String), TwitterAuthenticationFlowError> {
        return signinRequest.perform(with: url)
            .on(starting: { [weak self] in self?.state.swap(.requestingSignIn) })
            .attemptMap { url in
                return extractRequestTokenAndVerifier(from: url)
                    .mapError { TwitterAuthenticationFlowError.authorizationError($0) }
            }
    }

    func exchangeRequestToken(token: String, verifier: String) -> SignalProducer<(token: String, secret: String), TwitterAuthenticationFlowError> {
        return auth.requestAccessToken(token: token, verifier: verifier)
            .on(starting: { [weak self] in self?.state.swap(.exhangingRequestToken) })
            .mapError { .authorizationError($0) }
            .map { (token: $0.token, secret: $0.tokenSecret) }
    }
}

protocol KeychainType {
    func set(_ value: String, forKey name: String) -> Bool
    func get(_ key: String) -> String?
}

extension KeychainSwift: KeychainType {

    func set(_ value: String, forKey name: String) -> Bool {
        return set(value, forKey: name, withAccess: nil)
    }

}

protocol SigninRequestType {

    func perform(with url: URL) -> SignalProducer<URL, TwitterAuthenticationFlowError>

}

struct SignInRequest: SigninRequestType {

    func perform(with url: URL) -> SignalProducer<URL, TwitterAuthenticationFlowError> {
        return SignalProducer { sink, disposable in
            let session = SFAuthenticationSession(url: url, callbackURLScheme: "loop") { (url, error) in

                guard let url = url else {
                    sink.send(error: .internalError)
                    return
                }

                sink.send(value: url)
            }
            session.start()

            disposable.observeEnded { session.cancel() }
        }
    }
}

