import UIKit
import ReactiveSwift
import KeychainSwift
import LoopKit
import BirdNest
import CoreData
import os.log

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    let controller = UITabBarController()
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
        os_log("Initializing local storage...")
        let container = NSPersistentContainer(name: "Model")
        return container.reactive.load()
            .map(LocalStorage.init)
            .mapError { _ in .initStorage }
    }

    func signInWithTwitter() -> SignalProducer<Twitter, Error> {
        os_log("Signing in with twitter...")

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
        // TODO: move
        controller.tabBar.layer.shadowColor = ColorName.whiteTwo.color.cgColor
        controller.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        controller.tabBar.layer.shadowOpacity = 1;

        initLocalStorage()
            .flatMap(.latest, { storage in self.signInWithTwitter().map { (storage, $0) } })
            .startWithResult { [weak self] in
                switch $0 {
                case let .success((localStorage, twitter)):
                    let addLead = AddLeadCoordinator(storage: localStorage, client: twitter)
                    let allLeads = ListAllLeadsCoordinator(storage: localStorage)

                    self?.controller.viewControllers = [
                        addLead.controller,
                        UINavigationController(rootViewController: UIViewController()),
                        UINavigationController(rootViewController: UIViewController()),
                        allLeads.controller
                    ]

                    addLead.start()
                    allLeads.start()

                    self?.children.append(addLead)
                    self?.children.append(allLeads)
                case let .failure(error):
                    os_log("Unable to init app", log: .default, type: .error, error.localizedDescription)
                    BuddyBuildSDK.crash()
                }
        }
    }
}
