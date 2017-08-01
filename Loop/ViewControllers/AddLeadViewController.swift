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

    @IBOutlet weak var userListBottomConstraint: NSLayoutConstraint!
    let selectTwitter = Action<Source, Source, NoError> { value in
        return SignalProducer<Source, NoError>(value: value)
    }

    @IBOutlet weak var userList: UICollectionView!
    var twitterAction: CocoaAction<SourceSelector>!
    var client: Twitter?
    let source = MutableProperty(Source.twitter)

    private var users = [TwitterUser]()

    private var keyboardNotifications: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchField.reactive.continuousTextValues
            .filter { ($0?.count ?? 0) > 3 }
            .throttle(1, on: QueueScheduler.main)
            .flatMap(.latest, self.search)
            .observe(on: UIScheduler())
            .observeResult { [weak self] result in
                guard case let .success(users) = result else {
                    print("An error occured while fetching the users")
                    return
                }

                self?.users = users
                self?.userList.reloadData()

            }

        let center = NotificationCenter.default.reactive
        keyboardNotifications = Signal.merge(
            center.notifications(forName: .UIKeyboardWillChangeFrame),
            center.notifications(forName: .UIKeyboardWillHide),
            center.notifications(forName: .UIKeyboardWillShow)
        )
            .map(parse)
            .observe(on: UIScheduler())
            .observeValues { [weak self] args in
                if let (keyboardHeight, animationDuration, animationOptions) = args {
                    UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
                        self?.userListBottomConstraint.constant = keyboardHeight
                    }, completion: nil)
                } else {
                    self?.userListBottomConstraint.constant = 0
                }
            }
    }

    func search(for query: String?) -> SignalProducer<[TwitterUser], Twitter.Error> {
        guard let client = client, let query = query, !query.isEmpty else { return .empty }

        let request = TwitterUser.search(for: query)
        return client.execute(request)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        keyboardNotifications?.dispose()
    }
}

extension AddLeadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: userList.frame.width, height: 45)
    }
}

extension AddLeadViewController: UICollectionViewDelegate {
    
}

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

        cell.displayName.attributedText = createUserAttributedText(name: user.name, screenName: user.screenName)

        return cell
    }
}

func createUserAttributedText(name: String, screenName: String) -> NSAttributedString {
    let string = NSMutableAttributedString(string: name, attributes: [
        .font: UIFont(name: "SourceSansPro-SemiBold", size: 16)!,
        .foregroundColor: UIColor.lpBlack
    ])

    string.append(NSAttributedString(string: " @\(screenName)", attributes: [
        .font: UIFont(name: "SourceSansPro-Light", size: 16)!,
        .foregroundColor: UIColor.lpBlack
    ]))

    return string
}

