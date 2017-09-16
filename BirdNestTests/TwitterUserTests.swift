import XCTest
@testable import BirdNest

class TwitterUserTests: XCTestCase {

    func testTwitterUserDecoding() throws {
        let users: [TwitterUser] = try Fixture.User.searchForTwitterAPIUsers.decode()
        let expected = [
            TwitterUser(
                id: 6253282,
                screenName: "twitterapi",
                name: "Twitter API",
                profileImage: URL(string: "http://a0.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_normal.png")
            ),
            TwitterUser(
                id: 3963481,
                screenName: "twittermobile",
                name: "Twitter Mobile",
                profileImage: URL(string: "http://a0.twimg.com/profile_images/2284174879/uqyatg9dtld0rxx9anic_normal.png")
            ),
            TwitterUser(
                id: 6844292,
                screenName: "TwitterEng",
                name: "Twitter Engineering",
                profileImage: URL(string: "http://a0.twimg.com/profile_images/2284174594/apcu4c9tu2zkefnev0jt_normal.png")
            )
        ]

        XCTAssertEqual(users, expected)
    }
}
