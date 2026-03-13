final class CommentsNetwork: CommentsNetworkProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func createComment(id: String, data: CommentRequest) async throws -> Comment {
        let endPoint = CreateCommentEndpoint(id: id, body: data)

        return try await networkService.requestDecodable(
            endPoint,
            as: Comment.self
        )
    }

    func getComments(id: String) async throws -> [Comment] {
        let endPoint = GetCommentsEndpoint(id: id)

        return try await networkService.requestDecodable(
            endPoint,
            as: [Comment].self
        )
    }

    func deleteComment(id: String) async throws {
        let endPoint = DeleteCommentEndpoint(id: id)

        try await networkService.request(endPoint)
    }

    func editComment(id: String, data: CommentRequest) async throws -> Comment {
        let endPoint = EditCommentEndpoint(id: id, body: data)

        return try await networkService.requestDecodable(
            endPoint,
            as: Comment.self
        )
    }
}
