import Foundation

struct DeleteCommentEndpoint: EndPoint {
    private let id: String

    init(
        id: String
    ) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Comments.editComment(id: id) }
    var method: HTTPMethod { .delete }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
