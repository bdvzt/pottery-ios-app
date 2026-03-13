import Foundation

struct GetProfileEndpoint: EndPoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.profile }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
