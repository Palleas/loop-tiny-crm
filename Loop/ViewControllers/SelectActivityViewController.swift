import Foundation
import LoopKit
import Result
import ReactiveSwift
import os.log

final class SelectActivityViewController: UIViewController {

    @IBOutlet weak var activitiesList: UICollectionView! {
        didSet {
            activitiesList?.allowsMultipleSelection = true
            activitiesList?.register(UINib(nibName: "ActivityCell", bundle: .main), forCellWithReuseIdentifier: "ActivityCell")
        }
    }

    private let activities = Activity.all

    let didSelectActivities = Signal<[Activity], NoError>.pipe()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Remind Yourself"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
    }

    @objc func didTapDone() {
        guard let list = activitiesList.indexPathsForSelectedItems?.map({ activities[$0.row] }) else {
            os_log("No activities were selected: not notifying observer")
            return
        }

        didSelectActivities.input.send(value: list)
    }
}

extension SelectActivityViewController: UICollectionViewDelegate {

}

extension SelectActivityViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        // swiftlint:enable force_cast

        cell.icon.image = icon(for: activities[indexPath.row])
        cell.name.text = activities[indexPath.row].rawValue

        return cell
    }

}

func icon(for activity: Activity) -> UIImage {
    switch activity {
    case .call: return Asset.Activities.phoneHandset.image
    case .coffee: return Asset.Activities.coffeeCup.image
    case .event: return Asset.Activities.envelope.image
    case .interview: return Asset.Activities.bubble.image
    case .partnership: return Asset.Activities.apartment.image
    case .priority: return Asset.Activities.star.image
    case .sales: return Asset.Activities.user.image
    case .talent: return Asset.Activities.magicWand.image
    case .tshirt: return Asset.Activities.shirt.image
    }
}
