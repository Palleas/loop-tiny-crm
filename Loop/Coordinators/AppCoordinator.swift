import UIKit
import ReactiveSwift
import KeychainSwift
import LoopKit

final class AppCoordinator {

    let controller = UINavigationController()
    let consumerKey: String
    let consumerSecret: String

    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    func start() {
        let root = StoryboardScene.Main.addLeadScene.viewController()
        controller.viewControllers = [root]

        let auth = TwitterAuthorization(consumerKey: consumerKey, consumerSecret: consumerSecret, callback: "loop://welcome")
        let flow = TwitterAuthenticationFlow(auth: auth, signinRequest: SignInRequest(), keychain: KeychainSwift())
        flow.state.signal.logEvents().observeValues { print("State = \($0)") }
        flow.perform().startWithResult { print("Auth result \($0)") }
    }
}
