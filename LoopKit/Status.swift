import Foundation

struct Status {

    func update(includeEntities: Bool, status: String) -> Request<Status> {
        return Request(
            method: .post,
            path: "statuses/update.json",
            items: nil,
            body: [
                URLQueryItem(name: "include_entities", value: "\(includeEntities)"),
                URLQueryItem(name: "status", value: status)
            ]
        )

    }
}
