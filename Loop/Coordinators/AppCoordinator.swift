import UIKit
import ReactiveSwift
import KeychainSwift
import LoopKit

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    // TODO: use transition instead of NVC
    let controller = UINavigationController()
    let consumerKey: String
    let consumerSecret: String
    private var children = [Coordinator]()
    
    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    func start() {
        let root = StoryboardScene.Main.addLeadScene.viewController()
        controller.viewControllers = [root]

        let auth = TwitterAuthorization(consumerKey: consumerKey, consumerSecret: consumerSecret, callback: "loop://welcome")
        let flow = TwitterAuthenticationFlow(auth: auth, signinRequest: SignInRequest(), keychain: KeychainSwift())
        flow.perform().startWithResult { [weak self] result in
            // FIXME OMG
            guard let `self` = self else { return }

            switch result {
            case let .success(credentials):
                let credentials = Credentials(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, token: credentials.token, tokenSecret: credentials.secret)
                let twitter = Twitter(
                    credentials: credentials,
                    clock: Clock(),
                    tokenProvider: TokenProvider()
                )

                let child = AddLeadCoordinator(client: twitter)
                self.controller.viewControllers = [child.controller]
                child.start()

                self.children.append(child)
            case .failure:
                BuddyBuildSDK.crash()
            }

        }
    }
}
