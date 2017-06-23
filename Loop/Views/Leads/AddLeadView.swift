import UIKit
import LoopKit
import ReactiveSwift
import Result

final class AddLeadView: UIView {

    enum Source {
        case twitter
        case email
    }

    @IBOutlet weak var twitter: SourceSelector!

    @IBOutlet weak var mail: SourceSelector!

    var source = Signal<Source, NoError>.pipe()
}
