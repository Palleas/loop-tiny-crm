import Foundation

protocol BodyDecodable {
    init(decoder: BodyDecoderContainer) throws
}

enum BodyDecoderError: Error {
    case invalidFormat
    case noSuchKey(String)
}

func decode(line: String) throws -> (String, String) {
    let split = line.components(separatedBy: "=")

    guard split.count == 2 else {
        throw BodyDecoderError.invalidFormat
    }

    return (split[0], split[1])
}

final class BodyDecoderContainer {

    private let bag: [String: String]

    init(content: String) throws {
        self.bag = try content
            .components(separatedBy: "&")
            .map(decode)
            .reduce([String: String]()) { (acc, current) in
                let (key, value) = current
                var copy = acc
                copy[key] = value

                return copy
        }
    }

    func value(forKey key: String) throws -> String {
        guard let value = bag[key] else {
            throw BodyDecoderError.noSuchKey(key)
        }

        return value
    }

}

final class BodyDecoder {

    func decode<T: BodyDecodable>(_ type: T.Type, from content: String) throws -> T {
        return try T(decoder: BodyDecoderContainer(content: content))
    }

}
