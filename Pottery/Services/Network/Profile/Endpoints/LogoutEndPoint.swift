import Foundation

struct LogoutEndPoint: EndPoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Auth.logout }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
