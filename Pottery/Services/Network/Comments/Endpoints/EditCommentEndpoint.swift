import Foundation

struct EditCommentEndpoint: EndPoint {
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
    var path: String { APIConstants.Comments.editComment(id: id) }
    var method: HTTPMethod { .put }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
