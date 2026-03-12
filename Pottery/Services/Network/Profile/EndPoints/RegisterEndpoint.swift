import Foundation

struct RegisterEndpoint: EndPoint {
    private let body: RegisterRequest

    init(
        body: RegisterRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.register }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .none }
}
