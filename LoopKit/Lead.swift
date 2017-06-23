import Foundation

/// Represents a user on Twitter
public struct TwitterUser {
    /// Twitter User's handle (ex: @palleas)
    public let username: String

    /// Twitter User's fullname (ex: Romain Pouclet)
    public let fullname: String

    /// URL to a user's avatar
    public let avatar: URL?
}

/// Represents an Email address
public struct EmailAddress {

    /// String representation of an email
    public let raw: String
}

/// Represents a Lead in the database
public struct Lead {

    /// Represents the source of the lead
    ///
    /// - twitter: the lead comes from twitter
    /// - email: the lead comes from an email
    public enum Source {
        case twitter(TwitterUser)
        case email(EmailAddress)
    }

    /// The source the user got this lead from
    public let source: Source
}

