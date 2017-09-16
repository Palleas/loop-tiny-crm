import Foundation

public protocol TokenProviderProtocol {
    func generate() -> String
}

public struct TokenProvider: TokenProviderProtocol {
    public init() {}

    public func generate() -> String {
        return UUID().uuidString
    }
}
