import Foundation

struct JoinCourseEndpoint: EndPoint {
    private let body: JoinCourseRequest

    init(
        body: JoinCourseRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Courses.joinCourse }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
