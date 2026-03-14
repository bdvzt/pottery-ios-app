import Foundation
import UIKit
import Combine

@MainActor
final class AssignmentDetailsViewModel: ObservableObject {
    @Published var profile: ProfileResponse?

    @Published var selectedImages: [UIImage] = []
    @Published var isSubmitting = false
    @Published var mySubmission: SubmissionResponse?
    @Published var showCamera = false
    @Published var showGallery = false

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
    private let submissionsRepository: SubmissionsNetworkProtocol

    init(
        assignmentId: String,
        assignmentsRepository: AssignmentsNetworkProtocol,
        commentsRepository: CommentsNetworkProtocol,
        usersRepository: UsersNetworkProtocol,
        submissionsRepository: SubmissionsNetworkProtocol,
    ) {
        self.assignmentId = assignmentId
        self.assignmentsRepository = assignmentsRepository
        self.commentsRepository = commentsRepository
        self.usersRepository = usersRepository
        self.submissionsRepository = submissionsRepository
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

            do {
                let submission = try await submissionsRepository.getMySubmission(
                    assignmentId: assignmentId
                )

                if ((submission?.files.isEmpty) != nil) {
                    mySubmission = nil
                } else {
                    mySubmission = submission
                }
            } catch let error as NetworkError {
                switch error {
                case .serverError(let code, _):
                    if code == 404 {
                        mySubmission = nil
                    } else {
                        throw error
                    }
                default:
                    throw error
                }
            }

            let grades = try await assignmentsRepository.getMyGrades(id: assignmentResult.courseId)

            let uniqueGrades = Dictionary(
                grouping: grades,
                by: { $0.assignmentId }
            ).compactMap { $0.value.first }

            grade = uniqueGrades.first { $0.assignmentId == assignmentId }

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

    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }

    func submitSolution() async {

        guard !selectedImages.isEmpty else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {

            let files: [MultipartFormData] = selectedImages.compactMap { image in

                guard let data = image.jpegData(compressionQuality: 0.8) else {
                    return nil
                }

                return MultipartFormData(
                    name: "files",
                    filename: UUID().uuidString + ".jpg",
                    mimeType: "image/jpeg",
                    data: data
                )
            }

            _ = try await submissionsRepository.uploadFiles(
                assignmentId: assignmentId,
                files: files
            )

            selectedImages.removeAll()

            await loadAssignment()

        } catch {
            errorMessage = "Не удалось отправить решение"
        }
    }

    func deleteSubmission() async {

        guard let submission = mySubmission else { return }

        let fileIds = submission.files.map { $0.id }

         do {

             try await submissionsRepository.deleteSubmissionFiles(
                 submissionId: submission.id,
                 fileIds: fileIds
             )

            mySubmission = nil

        } catch {
            errorMessage = "Не удалось удалить решение"
        }
    }
}
