import UIKit
import LoopKit
import ReactiveSwift
import SafariServices
import Result
import KeychainSwift

final class ConnectWithTwitterViewController: UIViewController {
    private let auth = TwitterAuthorization(
        consumerKey: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_KEY"]!,
        consumerSecret: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_SECRET"]!,
        callback: "loop://welcome")

    let token = Signal<AccessTokenResponse, NoError>.pipe()

    @IBAction func connect(id: UIButton) {
        auth.requestToken()
            .observe(on: UIScheduler())
            .flatMap(.latest) { (token) -> SignalProducer<AccessTokenResponse, TwitterAuthorization.Error> in
                return SignalProducer { sink, disposable in
                    let session = SFAuthenticationSession(url: token.authenticate, callbackURLScheme: "loop", completionHandler: { (url, error) in

                        guard let url = url else {
                            sink.send(error: TwitterAuthorization.Error.invalidCompletionURL)
                            return
                        }

                        sink.send(value: url)

                    })
                    session.start()

                    disposable.observeEnded { session.cancel() }
                }
                .attemptMap { TwitterAuthorization.extractRequestTokenAndVerifier(from: $0) }
                .flatMap(.latest) { tokenResponse in
                    return self.auth.requestAccessToken(token: tokenResponse.token, verifier: tokenResponse.verifier)
                }
            }
            .attempt { response in
                return Result {
                    let keychain = KeychainSwift()
                    keychain.set(response.token, forKey: Keys.Twitter.oauthAccessToken)
                    keychain.set(response.tokenSecret, forKey: Keys.Twitter.oauthAccessTokenSecret)
                }
            }
            .startWithResult { [weak self] result in
                switch result {
                case let .success(token):
                    self?.token.input.send(value: token)
                    print("We got the token \(token)")
                case let .failure(error):
                    print("An error occured: \(error)")
                }
            }
    }
}

