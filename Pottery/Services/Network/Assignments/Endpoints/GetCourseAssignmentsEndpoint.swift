import Foundation

struct GetCourseAssignmentsEndpoint: EndPoint {
    private let id: String
    private let page: Int
    private let pageSize: Int

    init(
        id: String,
        page: Int = 1,
        pageSize: Int = 10
    ) {
        self.id = id
        self.page = page
        self.pageSize = pageSize
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String {
        APIConstants.Assignments.getCourseAssignments(id: id)
    }
    var method: HTTPMethod { .get }
    var task: HTTPTask {
        .requestUrlParameters([
            "page": page,
            "pageSize": pageSize
        ])
    }
    var authorization: AuthorizationRequirement { .accessToken }
}
