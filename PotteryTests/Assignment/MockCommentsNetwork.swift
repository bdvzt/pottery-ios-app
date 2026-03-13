import XCTest
@testable import Pottery

final class MockCommentsNetwork: CommentsNetworkProtocol {
    var getCommentsResult: Result<[Comment], Error> = .success([])
    var createCommentResult: Result<Comment, Error> = .failure(TestError.mock)
    var deleteCommentResult: Result<Void, Error> = .success(())
    var editCommentResult: Result<Comment, Error> = .failure(TestError.mock)

    func getComments(id: String) async throws -> [Comment] {
        try getCommentsResult.get()
    }

    func createComment(id: String, data: CommentRequest) async throws -> Comment {
        try createCommentResult.get()
    }

    func deleteComment(id: String) async throws {
        try deleteCommentResult.get()
    }

    func editComment(id: String, data: CommentRequest) async throws -> Comment {
        try editCommentResult.get()
    }
}
