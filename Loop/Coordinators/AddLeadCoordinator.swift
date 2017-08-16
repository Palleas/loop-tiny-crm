import Foundation
import LoopKit
import ReactiveSwift
import Result

final class AddLeadCoordinator: Coordinator {

    private let client: Twitter
    private let storage: LocalStorage

    let controller = UINavigationController()

    init(storage: LocalStorage, client: Twitter) {
        self.storage = storage
        self.client = client
    }

    func start() {
        let search = StoryboardScene.Main.instantiateAddLead()
        search.client = client
        controller.viewControllers = [search]

        search.didSelect.output
            .observe(on: UIScheduler())
            .flatMap(.latest, self.presentSelectActivity)
            .flatMap(.latest, self.save)
            .flatMap(.latest, self.presentConfirmation)
            .observeValues { selectedUser in
                print("Selected = \(selectedUser)")
            }
    }

    func save(user: TwitterUser, activities: [Activity]) -> SignalProducer<(TwitterUser, [Activity]), NoError> {
        return self.storage.save(user)
            .flatMapError { _ in SignalProducer<Lead, NoError>.empty }
            .map { _ in (user, activities) }
      }

    func presentConfirmation(user: TwitterUser, activities: [Activity]) -> Signal<(TwitterUser, [Activity]), NoError> {
        let confirmation = StoryboardScene.Main.instantiateLeadConfirmation()
        confirmation.viewModel.swap(LeadViewModel(
            username: user.name,
            fullname: user.screenName,
            avatar: user.profileImage?.ensureHTTPS(),
            activities: activities
        ))

        controller.pushViewController(confirmation, animated: true)
        
        return confirmation.didConfirm.output.map { (user, activities) }
    }

    func presentSelectActivity(user: TwitterUser) -> Signal<(TwitterUser, [Activity]), NoError> {
        let selectActivity = StoryboardScene.Main.instantiateSelectActivity()
        controller.pushViewController(selectActivity, animated: true)

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
