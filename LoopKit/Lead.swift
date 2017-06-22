import Foundation

/// Represents a user on Twitter
struct TwitterUser {
    /// Twitter User's handle (ex: @palleas)
    let username: String

    /// Twitter User's fullname (ex: Romain Pouclet)
    let fullname: String

    /// URL to a user's avatar
    let avatar: URL?
}

/// Represents an Email address
struct EmailAddress {

    /// String representation of an email
    let raw: String
}

/// Represents a Lead in the database
struct Lead {

    /// Represents the source of the lead
    ///
    /// - twitter: the lead comes from twitter
    /// - email: the lead comes from an email
    enum Source {
        case twitter(TwitterUser)
        case email(EmailAddress)
    }

    /// The source the user got this lead from
    let source: Source
}

