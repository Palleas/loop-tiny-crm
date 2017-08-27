//

import Foundation

final class ListAllLeadsCoordinator: Coordinator {

    let controller = UINavigationController()

    func start() {
        controller.viewControllers = [StoryboardScene.Main.listAllLeads.instantiate()]
    }
}
