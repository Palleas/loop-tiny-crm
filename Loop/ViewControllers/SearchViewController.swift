import UIKit
import ReactiveSwift

final class SearchViewController: UIViewController {

    let source = MutableProperty<AddLeadViewController.Source>(.twitter)

    @IBOutlet weak var searchField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        source.producer.startWithValues { source in
            print("Source = \(source)")
        }

        _ = searchField.reactive.continuousTextValues
            .throttle(1, on: QueueScheduler.main)
            .logEvents()
            .observeValues { print("Text = \($0 ?? "")") }
    }

}
