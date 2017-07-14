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
    static func search(for query: String) -> Request<[TwitterUser]> {
        return Request(
            method: .get,
            path: "users/search",
            items: [URLQueryItem(name: "q", value: query)],
            body: nil
        )
    }

    static func requestToken() -> Request<Any> {
        return Request(
            method: .post,
            path: "/oauth/request_token",
            items: nil,
            body: nil
        )
    }
}

extension TwitterUser: AutoEquatable {}
extension TwitterUser: AutoHashable {}

