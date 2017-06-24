import Foundation

protocol ClockProtocol {
    func now() -> TimeInterval
}

struct Clock: ClockProtocol {
    func now() -> TimeInterval {
        return Date().timeIntervalSinceReferenceDate
    }
}
