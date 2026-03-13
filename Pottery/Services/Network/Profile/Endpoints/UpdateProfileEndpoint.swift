import Foundation

struct UpdateProfileEndpoint: EndPoint {
    private let body: UpdateProfileRequest

    init(
        body: UpdateProfileRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.profile }
    var method: HTTPMethod { .patch }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
