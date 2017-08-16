import UIKit
import ReactiveSwift
import KeychainSwift
import LoopKit
import CoreData
import os.log

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    // TODO: use transition instead of NVC
    let controller = ContainerViewController()
    let consumerKey: String
    let consumerSecret: String
    private var children = [Coordinator]()

    enum Error: Swift.Error {
        case initStorage
        case signInWithTwitter
    }

    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    func initLocalStorage() -> SignalProducer<LocalStorage, Error> {
        print("Initializing local storage...")
        let container = NSPersistentContainer(name: "Model")
        return container.reactive.load()
            .map(LocalStorage.init)
            .mapError { _ in .initStorage }
    }

    func signInWithTwitter() -> SignalProducer<Twitter, Error> {
        print("Signing in with twitter...")

        let auth = TwitterAuthorization(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callback: "loop://welcome"
        )

        let flow = TwitterAuthenticationFlow(auth: auth, signinRequest: SignInRequest(), keychain: KeychainSwift())

        return flow
            .perform()
            .map { credentials -> Twitter in
                let credentials = Credentials(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, token: credentials.token, tokenSecret: credentials.secret)

                return Twitter(
                    credentials: credentials,
                    clock: Clock(),
                    tokenProvider: TokenProvider()
                )
            }
            .mapError { _ in .signInWithTwitter }
    }

    func start() {
        initLocalStorage()
            .zip(with: signInWithTwitter())
            .startWithResult { [weak self] in
                switch $0 {
                case let .success((localStorage, twitter)):
                    let child = AddLeadCoordinator(storage: localStorage, client: twitter)
                    self?.controller.transition(to: child.controller)
                    child.start()
                    self?.children.append(child)

                case let .failure(error):
                    os_log("Unable to init app", log: .default, type: .error, error.localizedDescription)
                    BuddyBuildSDK.crash()
                }
        }
    }
}

