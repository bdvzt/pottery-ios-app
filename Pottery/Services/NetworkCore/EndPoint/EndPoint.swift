import Foundation

protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: HTTPTask { get }

    var authorization: AuthorizationRequirement { get }
}
