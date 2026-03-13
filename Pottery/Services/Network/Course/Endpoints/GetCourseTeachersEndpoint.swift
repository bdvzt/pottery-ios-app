import Foundation

struct GetCourseTeachersEndpoint: EndPoint {
    private let id: String

    init(
        id: String
    ) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Courses.teachers(id: id) }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
