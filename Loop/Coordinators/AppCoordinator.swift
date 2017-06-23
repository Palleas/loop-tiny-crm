import UIKit

final class AppCoordinator {

    let controller = UINavigationController()

    func start() {
        let root = StoryboardScene.Main.addLeadScene.viewController()
        controller.viewControllers = [root]
    }
}
