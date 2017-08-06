import Foundation
import LoopKit
import ReactiveSwift

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
            .observeValues { [weak self] selectedUser in
                let controller = StoryboardScene.Main.instantiateSelectActivity()
                self?.controller.pushViewController(controller, animated: true)
                print("Selected = \(selectedUser)")
        }
    }
}

