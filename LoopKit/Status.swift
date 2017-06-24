import Foundation

struct UpdateStatus: Request {
    let method = Method.post
    let path = "statuses/update.json"

    let includeEntities: Bool
    let status: String

    let items = [URLQueryItem]()

    var body: [URLQueryItem] {
        return [
            URLQueryItem(name: "include_entities", value: "\(includeEntities)"),
            URLQueryItem(name: "status", value: status)
        ]
    }

}
