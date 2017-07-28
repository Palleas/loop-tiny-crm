import Foundation
import LoopKit

final class AddLeadCoordinator: Coordinator {

    private let client: Twitter

    let controller = StoryboardScene.Main.instantiateAddLead()

    init(client: Twitter) {
        self.client = client
    }

    func start() {

    }
}
