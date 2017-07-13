import Foundation

struct RequestToken: Request {
    let method = Method.post
    let path = "/oauth/request_token"
    let items = [URLQueryItem]()
    let body = [URLQueryItem]()
}
