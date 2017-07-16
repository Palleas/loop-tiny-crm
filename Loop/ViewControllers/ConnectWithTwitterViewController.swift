import UIKit
import LoopKit
import ReactiveSwift

final class ConnectWithTwitterViewController: UIViewController {
    private let auth = TwitterAuthorization(
        consumerKey: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_KEY"]!,
        consumerSecret: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_SECRET"]!,
        callback: "loop://welcome")

    @IBAction func connect(id: UIButton) {
        auth.requestToken().startWithResult { result in
            switch result {
            case let .success(token):
                print("We got the token \(token)")
            case let .failure(error):
                print("An error occured: \(error)")
            }

        }
    }
}

