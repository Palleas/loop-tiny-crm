import Foundation
import LoopKit
import ReactiveSwift
import Result

final class AddLeadCoordinator: Coordinator {

    private let client: Twitter

    let controller = UINavigationController()

    init(client: Twitter) {
        self.client = client
    }

    func start() {
        let search = StoryboardScene.Main.instantiateAddLead()
        search.client = client
        controller.viewControllers = [search]

        search.didSelect.output
            .observe(on: UIScheduler())
            .flatMap(.latest, self.presentSelectActivity)
            .observeValues { selectedUser in
                print("Selected = \(selectedUser)")
            }
    }

    func presentSelectActivity(user: TwitterUser) -> Signal<(TwitterUser, [Activity]), NoError> {
        let selectActivity = StoryboardScene.Main.instantiateSelectActivity()
        controller.pushViewController(selectActivity, animated: true)

        return selectActivity.didSelectActivities.output.map { (user, $0) }
    }
}
