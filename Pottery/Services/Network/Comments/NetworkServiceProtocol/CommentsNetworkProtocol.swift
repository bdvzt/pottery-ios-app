protocol CommentsNetworkProtocol {
    func createComment(id: String, data: CommentRequest) async throws -> Comment
    func getComments(id: String) async throws -> [Comment]
    func deleteComment(id: String) async throws
    func editComment(id: String, data: CommentRequest) async throws -> Comment
}
