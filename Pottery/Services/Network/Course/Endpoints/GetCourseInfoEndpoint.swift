import Foundation

struct GetCourseInfoEndpoint: EndPoint {
    private let id: String

    init(
        id: String
    ) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Courses.getCourseInfo(id: id) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
