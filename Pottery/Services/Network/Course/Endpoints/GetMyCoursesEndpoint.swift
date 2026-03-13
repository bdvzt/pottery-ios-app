import Foundation

struct GetMyCoursesEndpoint: EndPoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Courses.getMyCourses }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
