import Foundation
import ReactiveSwift

final class TwitterAuthorization {

    struct Token {
        let raw: String
    }

    enum Error: Swift.Error {

    }

    private let requestCreator: OAuthRequestCreator

    public init(requestCreator: OAuthRequestCreator) {
        self.requestCreator = requestCreator
    }

    func requestToken() -> SignalProducer<Token, Error> {
        return .empty
    }

}
