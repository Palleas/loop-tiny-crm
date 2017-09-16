import Foundation

public protocol ClockProtocol {
    func now() -> TimeInterval
}

public struct Clock: ClockProtocol {

    public init() {}

    public func now() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}
