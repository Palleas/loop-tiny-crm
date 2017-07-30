import UIKit
import ReactiveSwift

final class SearchViewController: UIViewController {

    var datasource: UserSearchDatasource?

    @IBOutlet weak var searchField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let datasource = datasource else { return }

        datasource.query <~ searchField.reactive.continuousTextValues.logEvents()
            .throttle(1, on: QueueScheduler.main)

    }
}
