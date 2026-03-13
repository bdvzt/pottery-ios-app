import Foundation

struct GetCommentsEndpoint: EndPoint {
    private let id: String

    init(
        id: String
    ) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Comments.assignmentComment(id: id) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
