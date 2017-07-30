import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import LoopKit

final class AddLeadViewController: UIViewController {
    enum Source {
        case twitter
        case mail
    }
    
    @IBOutlet weak var searchField: UITextField!

    let selectTwitter = Action<Source, Source, NoError> { value in
        return SignalProducer<Source, NoError>(value: value)
    }

    @IBOutlet weak var userList: UICollectionView!
    var twitterAction: CocoaAction<SourceSelector>!
    var client: Twitter?
    let source = MutableProperty(Source.twitter)

    private var users = [TwitterUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchField.reactive.continuousTextValues
            .throttle(1, on: QueueScheduler.main)
            .flatMap(.latest, self.search)
            .observe(on: UIScheduler())
            .observeResult { [weak self] result in
                print("Result = \(result)")
                guard case let .success(users) = result else {
                    print("An error occured while fetching the users")
                    return
                }

                self?.users = users
                self?.userList.reloadData()

            }
    }

    func search(for query: String?) -> SignalProducer<[TwitterUser], Twitter.Error> {
        guard let client = client, let query = query, !query.isEmpty else { return .empty }

        let request = TwitterUser.search(for: query)
        return client.execute(request)
    }

}

extension AddLeadViewController: UICollectionViewDelegate {}

extension AddLeadViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell

        // load image
        let user = users[indexPath.row]
        if let url = user.profileImage {
            // ensure HTTPs
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            comps?.scheme = "https"

            let request = URLRequest(url: comps!.url!)
            URLSession.shared.reactive
                .data(with: request)
                .take(until: cell.reactive.prepareForReuse)
                .flatMapError { _ in SignalProducer<(Data, URLResponse), NoError>.empty }
                .map { $0.0 }
                .observe(on: UIScheduler())
                .startWithValues { cell.avatar.image = UIImage(data: $0) }
        }

        cell.displayName.text = "\(user.name) \(user.screenName)"

        return cell
    }
}

