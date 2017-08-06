import Foundation
import LoopKit
final class SelectActivityViewController: UIViewController {

    @IBOutlet weak var activitiesList: UICollectionView!

    private let activities = Activity.all
}

extension SelectActivityViewController: UICollectionViewDelegate {}

extension SelectActivityViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell

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
