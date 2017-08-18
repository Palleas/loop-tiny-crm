import Foundation
import LoopKit
import ReactiveSwift
import Result
import os.log

final class AddLeadCoordinator: Coordinator {

    private let client: Twitter
    private let storage: LocalStorage

    let controller = UINavigationController()

    init(storage: LocalStorage, client: Twitter) {
        self.storage = storage
        self.client = client
    }

    func start() {
        let search = StoryboardScene.Main.addLead.instantiate()
        search.client = client
        controller.viewControllers = [search]

        search.didSelect.output
            .observe(on: UIScheduler())
            .flatMap(.latest, self.presentSelectActivity)
            .flatMap(.latest, self.save)
            .flatMap(.latest, self.presentConfirmation)
            .logEvents()
            .observeValues { selectedUser in
                print("Selected = \(selectedUser)")
            }
    }

    func save(user: TwitterUser, activities: [Activity]) -> SignalProducer<(TwitterUser, [Activity]), NoError> {
        os_log("Saving user %@ with activities %@", [user, activities])

        return self.storage.save(user)
            .logEvents()
            .flatMapError { _ in SignalProducer<Lead, NoError>.empty }
            .map { _ in (user, activities) }
      }

    func presentConfirmation(user: TwitterUser, activities: [Activity]) -> Signal<(TwitterUser, [Activity]), NoError> {
        os_log("Presenting confirmation for user %@ with activities", [user, activities])

        let confirmation = StoryboardScene.Main.leadConfirmation.instantiate()
        confirmation.viewModel.swap(LeadViewModel(
            username: user.name,
            fullname: user.screenName,
            avatar: user.profileImage?.ensureHTTPS(),
            activities: activities
        ))

        UIScheduler().schedule { [weak self] in
            self?.controller.pushViewController(confirmation, animated: true)
        }


        return confirmation.didConfirm.output.map { (user, activities) }
    }

    func presentSelectActivity(user: TwitterUser) -> Signal<(TwitterUser, [Activity]), NoError> {
        os_log("Presenting select activities for user %@", [user])

        let selectActivity = StoryboardScene.Main.selectActivity.instantiate()

        UIScheduler().schedule { [weak self] in
            self?.controller.pushViewController(selectActivity, animated: true)
        }

        return selectActivity.didSelectActivities.output.map { (user, $0) }
    }
}

extension URL {
    func ensureHTTPS() -> URL {
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        comps.scheme = "https"

        return comps.url!
    }
}
