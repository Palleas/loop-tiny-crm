//
import LoopKit
import Foundation
import ReactiveSwift
import Result

final class UserSearchDatasource {

    private let twitter: Twitter

    enum Error: Swift.Error {
        case searchError
    }

    let source = MutableProperty<AddLeadViewController.Source>(.twitter)
    let query = MutableProperty<String?>(nil)

    let users = MutableProperty<[TwitterUser]>([])

    var cache: Any?
    init(twitter: Twitter) {
        self.twitter = twitter

        cache = SignalProducer.combineLatest(source, query.signal.skipNil())
            .logEvents()
            .flatMap(.concat, self.search)
            .flatMapError { _ in SignalProducer<[TwitterUser], NoError>.empty }
            .startWithValues { self.users.swap($0) }

        users.signal.observeValues { print("Users = \($0)") }
//        query.signal.observeValues { print("Query = \($0)") }

    }

    func search(in source: AddLeadViewController.Source, for query: String) -> SignalProducer<[TwitterUser], Error> {
        let query = TwitterUser.search(for: query)
        return twitter.execute(query).mapError { _ in Error.searchError }
    }
}
