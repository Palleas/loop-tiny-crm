import UIKit
import ReactiveSwift
import KeychainSwift
import LoopKit

final class AppCoordinator {

    let controller = UINavigationController()

    func start() {
        let root = StoryboardScene.Main.addLeadScene.viewController()
        controller.viewControllers = [root]

        let keychain = KeychainSwift()
        if let token = keychain.get(Keys.Twitter.oauthAccessToken),
            let tokenSecret = keychain.get(Keys.Twitter.oauthAccessTokenSecret) {
            let credentials = Credentials(
                consumerKey: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_KEY"]!,
                consumerSecret: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_SECRET"]!,
                token: token, tokenSecret: tokenSecret
            )

            let twitter = Twitter(credentials: credentials, clock: Clock(), tokenProvider: TokenProvider())
            let search = TwitterUser.search(for: "pouclet")

            twitter.execute(search).startWithResult { result in
                print("Search result = \(result)")
            }
        } else {
            let connect = StoryboardScene.Main.instantiateConnectWithTwitter()
            controller.present(connect, animated: true, completion: nil)

            connect.token.output.observe(on: UIScheduler()).observeValues { [weak self] token in
                self?.controller.dismiss(animated: true, completion: nil)
            }
        }
    }
}
