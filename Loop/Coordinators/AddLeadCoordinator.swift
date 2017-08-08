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
            .flatMap(.latest, { [weak self] user -> Signal<(TwitterUser, [Activity]), NoError> in
                let controller = StoryboardScene.Main.instantiateSelectActivity()
                self?.controller.pushViewController(controller, animated: true)

                return controller.didSelectActivities.output.map { (user, $0) }
            })
            .observeValues { selectedUser in
                print("Selected = \(selectedUser)")
            }
    }
}
