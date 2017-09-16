import Foundation
import LoopKit
import Result

final class ListAllLeadsCoordinator: Coordinator {

    let controller = UINavigationController()
    let storage: LocalStorage

    init(storage: LocalStorage) {
        self.storage = storage
    }

    func start() {
        let leadsViewController: ListLeadsViewController = StoryboardScene.Main.listAllLeads.instantiate()
        controller.viewControllers = [leadsViewController]

        let leads: Result<[TwitterUser], LocalStorage.Error> = storage.list()
        switch leads {
        case let .success(leads):
            print("Found \(leads)")
            leadsViewController.leads = leads
        case let .failure(error):
            print("Got error \(error)")
        }
    }
}
