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

    var twitterAction: CocoaAction<SourceSelector>!
    var client: Twitter?
    let source = MutableProperty(Source.twitter)

    override func viewDidLoad() {
        super.viewDidLoad()

//        let mainView = view as! AddLeadView
//
//        twitterAction = CocoaAction(selectTwitter, { button -> Source in
//            if button === mainView.twitter {
//                return .twitter
//            }
//
//            return .mail
//        })
//
//        mainView.twitter.addTarget(twitterAction, action: CocoaAction<SourceSelector>.selector, for: .touchUpInside)
//        mainView.mail.addTarget(twitterAction, action: CocoaAction<SourceSelector>.selector, for: .touchUpInside)
//
//        mainView.twitter.reactive.isSelected <~ source.producer.map { $0 == .twitter }
//        mainView.mail.reactive.isSelected <~ source.producer.map { $0 == .mail }
//
//        source <~ selectTwitter.values

//        searchField.reactive.continuousTextValues.flatMap(.latest) { query -> SignalProducerConvertible in
//            guard let client = client else { return .empty }
//        }
//        SignalProducer.combineLatest(source.producer, searchField.reactive.continuousTextValues)
//            .flatMap(FlattenStrategy.merge) { arg in
//                let (source, query) = arg
//                print("Source = \(source)")
//                print("Query = \(query)")
//            }

        let twitterUsers = searchField.reactive.continuousTextValues
            .throttle(1, on: QueueScheduler.main)
            .flatMap(.latest, self.search)
            .observe(on: UIScheduler())
            .observeResult { result in
                print("Result = \(result)")
            }
    }

    func search(for query: String?) -> SignalProducer<[TwitterUser], Twitter.Error> {
        guard let client = client, let query = query, !query.isEmpty else { return .empty }

        let request = TwitterUser.search(for: query)
        return client.execute(request)
    }

}
