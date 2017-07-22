import Foundation

/// Represents a user on Twitter
public struct TwitterUser: Identifiable, Decodable {
    /// Twitter User's ID
    public let id: ID<TwitterUser>

    /// Twitter User's handle (ex: @palleas)
    public let screenName: String

    /// Twitter User's fullname (ex: Romain Pouclet)
    public let name: String

    /// URL to a user's avatar
    public let profileImage: URL?

    private enum CodingKeys: String, CodingKey {
        case id
        case screenName = "screen_name"
        case name
        case profileImage = "profile_image_url"
    }
}

extension TwitterUser {
    public static func search(for query: String) -> Request<[TwitterUser]> {
        return Request(
            method: .get,
            path: "users/search.json",
            items: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "count", value: "10")
            ],
            body: nil
        )
    }

    public static func verifyCredentials() -> Request<TwitterUser> {
        return Request(
            method: .get,
            path: "account/verify_credentials.json",
            items: nil,
            body: nil
        )
    }
}

extension TwitterUser: AutoEquatable {}
extension TwitterUser: AutoHashable {}

