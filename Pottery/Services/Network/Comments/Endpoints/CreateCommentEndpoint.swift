import Foundation

struct CreateCommentEndpoint: EndPoint {
    private let id: String
    private let body: CommentRequest

    init(
        id: String,
        body: CommentRequest
    ) {
        self.id = id
        self.body = body
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Comments.assignmentComment(id: id) }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
