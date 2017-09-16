// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - TokenResponse AutoEquatable
extension TokenResponse: Equatable {}
public func == (lhs: TokenResponse, rhs: TokenResponse) -> Bool {
    guard lhs.token == rhs.token else { return false }
    guard lhs.tokenSecret == rhs.tokenSecret else { return false }
    guard lhs.callbackConfirmed == rhs.callbackConfirmed else { return false }
    return true
}
// MARK: - TwitterUser AutoEquatable
extension TwitterUser: Equatable {}
public func == (lhs: TwitterUser, rhs: TwitterUser) -> Bool {
    guard lhs.id == rhs.id else { return false }
    guard lhs.screenName == rhs.screenName else { return false }
    guard lhs.name == rhs.name else { return false }
    guard compareOptionals(lhs: lhs.profileImage, rhs: rhs.profileImage, compare: ==) else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
