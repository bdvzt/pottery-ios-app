import Foundation
import Combine

@MainActor
final class AssignmentDetailsViewModel: ObservableObject {
    @Published var profile: ProfileResponse?

    @Published var assignment: AssignmentResponse?
    @Published var comments: [Comment] = []

    @Published var commentText: String = ""

    @Published var isLoading = false
    @Published var isSendingComment = false
    @Published var errorMessage: String?

    @Published var grade: Grade?

    private let assignmentId: String
    private let assignmentsRepository: AssignmentsNetworkProtocol
    private let commentsRepository: CommentsNetworkProtocol
    private let usersRepository: UsersNetworkProtocol

    init(
        assignmentId: String,
        assignmentsRepository: AssignmentsNetworkProtocol,
        commentsRepository: CommentsNetworkProtocol,
        usersRepository: UsersNetworkProtocol
    ) {
        self.assignmentId = assignmentId
        self.assignmentsRepository = assignmentsRepository
        self.commentsRepository = commentsRepository
        self.usersRepository = usersRepository
    }

    func loadAssignment() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await loadProfile()

        do {
            async let assignmentRequest = assignmentsRepository.getAssignment(id: assignmentId)
            async let commentsRequest = commentsRepository.getComments(id: assignmentId)

            let assignmentResult = try await assignmentRequest
            assignment = assignmentResult
            comments = try await commentsRequest

            let grades = try await assignmentsRepository.getMyGrades(id: assignmentResult.courseId)

            grade = grades.first { $0.assignmentId == assignmentId }
        } catch {
            errorMessage = "Не удалось загрузить задание"
        }
    }

    func sendComment() async {
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { return }

        isSendingComment = true
        defer { isSendingComment = false }

        do {
            let comment = try await commentsRepository.createComment(
                id: assignmentId,
                data: CommentRequest(text: text)
            )

            comments.insert(comment, at: 0)
            commentText = ""
            await loadAssignment()

        } catch {
            errorMessage = "Не удалось отправить комментарий"
        }
    }

    func deleteComment(_ comment: Comment) async {
        do {
            try await commentsRepository.deleteComment(id: comment.id)
            comments.removeAll { $0.id == comment.id }
            await loadAssignment()
        } catch {
            errorMessage = "Не удалось удалить комментарий"
        }
    }

    func editComment(_ comment: Comment, text: String) async {
        do {
            let updated = try await commentsRepository.editComment(
                id: comment.id,
                data: CommentRequest(text: text)
            )

            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                comments[index] = updated
            }
            await loadAssignment()

        } catch {
            errorMessage = "Не удалось изменить комментарий"
        }
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await usersRepository.getProfile()
        } catch {
            errorMessage = "Не удалось загрузить профиль"
        }
    }
}
