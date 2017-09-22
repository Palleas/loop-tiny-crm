import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import LoopKit
import BirdNest
import os.log

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

    let didSelect = Signal<TwitterUser, NoError>.pipe()

    private var users = [TwitterUser]()
    private var keyboardNotifications: Disposable?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.tabBarItem = UITabBarItem(title: "Add Lead", image: Asset.Menu.userPlus.image, selectedImage: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchField.reactive.continuousTextValues
            .filter { ($0?.count ?? 0) > 3 }
            .throttle(1, on: QueueScheduler.main)
            .flatMap(.latest, self.search)
            .observe(on: UIScheduler())
            .observeResult { [weak self] result in
                guard case let .success(users) = result else {
                    os_log("An error occured while fetching the users", log: OSLog.default, type: .error)
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < users.count else {
            os_log("Invalid indexpath %@", log: .default, type: .error, [indexPath])
            return
        }

        didSelect.input.send(value: users[indexPath.row])
    }
}

extension AddLeadViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        // swiftlint:enable force_cast

        // load image
        let user = users[indexPath.row]
        if let url = user.profileImage {
            // ensure HTTPs
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            comps?.scheme = "https"

            let request = URLRequest(url: comps!.url!)
            URLSession.shared.reactive
                .data(with: request)
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
        .font: FontFamily.SourceSansPro.semiBold.font(size: 16),
        .foregroundColor: ColorName.black.color
    ])

    string.append(NSAttributedString(string: " @\(screenName)", attributes: [
        .font: FontFamily.SourceSansPro.light.font(size: 16),
        .foregroundColor: ColorName.black.color
    ]))

    return string
}
