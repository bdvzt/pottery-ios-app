import Foundation

struct DeleteProfileEndpoint: EndPoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.profile }
    var method: HTTPMethod { .delete }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
