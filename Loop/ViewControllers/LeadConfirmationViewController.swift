import UIKit
import ReactiveSwift
import Result
import LoopKit

struct LeadViewModel {
    let username: String
    let fullname: String
    let avatar: URL?
    let activities: [Activity]
}

class LeadConfirmationViewController: UIViewController {

    @IBOutlet weak var activitiesList: UICollectionView! {
        didSet {
            activitiesList?.register(UINib(nibName: "ActivityCell", bundle: .main), forCellWithReuseIdentifier: "ActivityCell")
        }
    }

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!

    let viewModel = MutableProperty<LeadViewModel?>(nil)

    let didConfirm = Signal<(), NoError>.pipe()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        username.reactive.text <~ viewModel.map { $0?.username }
        fullname.reactive.text <~ viewModel.map { $0?.fullname }
        userAvatar.reactive.image <~ viewModel.signal
            .map { $0?.avatar }
            .skipNil()
            .flatMap(.latest, loadImage)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
    }

    @objc func didTapDone() {
        didConfirm.input.send(value: ())
    }
}

func loadImage(from url: URL) -> SignalProducer<UIImage?, NoError> {
    return URLSession.shared.reactive
        .data(with: URLRequest(url: url))
        .map { UIImage(data: $0.0) }
        .flatMapError { _ in SignalProducer<UIImage?, NoError>(value: nil) }
        .observe(on: UIScheduler())
}
