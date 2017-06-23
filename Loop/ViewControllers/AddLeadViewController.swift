import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

final class AddLeadViewController: UIViewController {
    enum Source {
        case twitter
        case mail
    }

    let selectTwitter = Action<Source, Source, NoError> { value in
        return SignalProducer<Source, NoError>(value: value)
    }

    var twitterAction: CocoaAction<SourceSelector>!

    let source = MutableProperty(Source.twitter)

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainView = view as! AddLeadView

        twitterAction = CocoaAction(selectTwitter, { button -> Source in
            if button === mainView.twitter {
                return .twitter
            }

            return .mail
        })

        mainView.twitter.addTarget(twitterAction, action: CocoaAction<SourceSelector>.selector, for: .touchUpInside)
        mainView.mail.addTarget(twitterAction, action: CocoaAction<SourceSelector>.selector, for: .touchUpInside)

        mainView.twitter.reactive.isSelected <~ source.producer.map { $0 == .twitter }
        mainView.mail.reactive.isSelected <~ source.producer.map { $0 == .mail }

        source <~ selectTwitter.values
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard segue.identifier == StoryboardSegue.Main.userSearch.rawValue else {
            return
        }

        let search = segue.destination as! SearchViewController
        search.source <~ source
    }

}
