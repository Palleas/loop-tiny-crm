import UIKit
import ReactiveSwift

final class SearchViewController: UIViewController {

    let source = MutableProperty<AddLeadViewController.Source>(.twitter)

    override func viewDidLoad() {
        super.viewDidLoad()

        source.producer.startWithValues { source in
            print("Source = \(source)")
        }
    }
}
