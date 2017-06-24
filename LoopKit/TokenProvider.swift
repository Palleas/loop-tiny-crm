import Foundation

protocol TokenProviderProtocol {
    func generate() -> String
}

struct TokenProvider: TokenProviderProtocol {
    func generate() -> String {
        return UUID().uuidString
    }
}
