import Foundation
@testable import LoopKit

final class DummyRequest {}

protocol FixtureType {

    var fixturePath: String { get }

}

extension FixtureType {
    func decode<T: Decodable>() throws -> T {
        let content = try Data(contentsOf: URL(fileURLWithPath: fixturePath))

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: content)
    }
}

extension Request: FixtureType {

    var fixturePath: String {
        let anythingButLetters = CharacterSet.alphanumerics.inverted
        let items = self.items?
            .map { $0.name + "-" + ($0.value?.components(separatedBy: anythingButLetters).joined(separator: "-") ?? "")  }
            .joined(separator: "-")

        let filename: String = [method.rawValue, path.components(separatedBy: anythingButLetters).joined(separator: "-"), items]
            .flatMap { $0 }
            .joined(separator: "-")

        return Bundle(for: DummyRequest.self).path(forResource: filename, ofType: "json")!
    }

}

struct Fixture {
    struct User {

        static let searchForTwitterAPIUsers = TwitterUser.search(for: "Twitter API")

    }
}
