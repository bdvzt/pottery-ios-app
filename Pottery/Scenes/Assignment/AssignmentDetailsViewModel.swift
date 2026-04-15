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
    @Published var assignmentTeams: [AssignmentTeam] = []
    @Published var myTeam: AssignmentTeam?
    @Published var captainContext: CaptainAssignmentContextResponse?
    @Published private(set) var isVolunteerCaptain = false

    @Published var commentText: String = ""

    @Published var isLoading = false
    @Published var isSendingComment = false
    @Published var isUpdatingTeam = false
    @Published var errorMessage: String?
    @Published var teamErrorMessage: String?

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
        teamErrorMessage = nil
        defer { isLoading = false }

        await loadProfile()

        await loadAssignmentDetails()
        await loadComments()
        await reloadTeams()
        await loadCaptainState()
        await loadSubmission()
        await loadGrade()
    }

    private func loadAssignmentDetails() async {
        do {
            assignment = try await assignmentsRepository.getAssignment(id: assignmentId)
        } catch let error as NetworkError {
            switch error {
            case .serverError(let code, _):
                if code == 403 {
                    errorMessage = "Задание скрыто"
                } else {
                    errorMessage = "Не удалось загрузить задание"
                }
            default:
                errorMessage = "Не удалось загрузить задание"
            }
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
        do {
            profile = try await usersRepository.getProfile()
            resolveMyTeam()
        } catch {
            errorMessage = "Не удалось загрузить профиль"
        }
    }

    func joinTeam(_ team: AssignmentTeam) async {
        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        do {
            try await assignmentsRepository.joinAssignmentTeam(teamId: team.id)
            await reloadTeams()
            await loadCaptainState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось вступить в команду")
        }
    }

    func createTeam(name: String) async {
        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        guard let assignment else { return }

        if assignment.isTeacherManagedTeamFormation {
            teamErrorMessage = "В этом задании команды формирует преподаватель."
            return
        }

        if assignment.requiresCaptainVolunteerBeforeCreatingTeam, !isVolunteerCaptain {
            teamErrorMessage = "Сначала нажмите «Стать капитаном», затем создайте команду."
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            _ = try await assignmentsRepository.createAssignmentTeam(
                assignmentId: assignmentId,
                name: trimmedName.isEmpty ? nil : trimmedName
            )
            await reloadTeams()
            await loadCaptainState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось создать команду")
        }
    }

    func selfAssignAsCaptain() async {
        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        guard let assignment else { return }

        guard assignment.allowsStudentCaptainSelfService else {
            teamErrorMessage = "Самовыбор капитана недоступен для этого задания."
            return
        }

        guard assignment.isCaptainSelectionWindowOpen else {
            teamErrorMessage = "Этап выбора капитанов уже завершён."
            return
        }

        do {
            try await assignmentsRepository.selfAssignCaptain(assignmentId: assignmentId)
            await reloadTeams()
            await loadCaptainState()
            if assignment.requiresCaptainVolunteerBeforeCreatingTeam, !isVolunteerCaptain {
                isVolunteerCaptain = true
            }
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось записаться капитаном")
        }
    }

    func withdrawCaptainVolunteer() async {
        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        guard let assignment else { return }

        guard assignment.allowsStudentCaptainSelfService else { return }

        guard assignment.isCaptainSelectionWindowOpen else {
            teamErrorMessage = "Снять себя с роли капитана сейчас нельзя: этап завершён."
            return
        }

        do {
            try await assignmentsRepository.withdrawSelfAsCaptain(assignmentId: assignmentId)
            isVolunteerCaptain = false
            await reloadTeams()
            await loadCaptainState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось снять роль капитана")
        }
    }

    func leaveMyTeam() async {
        guard let teamId = myTeam?.id else { return }

        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        do {
            try await assignmentsRepository.leaveAssignmentTeam(teamId: teamId)
            await reloadTeams()
            await loadCaptainState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось выйти из команды")
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

    private func loadCaptainState() async {
        guard assignment != nil else {
            captainContext = nil
            isVolunteerCaptain = false
            return
        }

        do {
            captainContext = try await assignmentsRepository.getMyCaptainContext(assignmentId: assignmentId)
        } catch {
            captainContext = nil
        }

        await syncVolunteerCaptainFromServer()
    }

    private func syncVolunteerCaptainFromServer() async {
        guard let assignment,
              assignment.allowsStudentCaptainSelfService,
              let profileId = profile?.id
        else {
            isVolunteerCaptain = false
            return
        }

        do {
            let list = try await assignmentsRepository.getAssignmentCaptains(assignmentId: assignmentId)
            isVolunteerCaptain = list.contains(where: { $0.matchesUser(profileId) })
        } catch {
            // не меняем isVolunteerCaptain: при ошибке сети не затираем локальное состояние
        }
    }

    private func reloadTeams() async {
        do {
            assignmentTeams = try await assignmentsRepository.getAssignmentTeams(assignmentId: assignmentId)
            resolveMyTeam()
        } catch let error as NetworkError {
            if case .serverError(let code, _) = error, code == 403 {
                assignmentTeams = []
                myTeam = nil
                return
            }
            teamErrorMessage = "Не удалось обновить команды"
        } catch {
            teamErrorMessage = "Не удалось обновить команды"
        }
    }

    private func loadComments() async {
        do {
            comments = try await commentsRepository.getComments(id: assignmentId)
        } catch {
            comments = []
        }
    }

    private func loadSubmission() async {
        do {
            let submission = try await submissionsRepository.getMySubmission(
                assignmentId: assignmentId
            )

            if let submission, !submission.files.isEmpty {
                mySubmission = submission
            } else {
                mySubmission = nil
            }
        } catch let error as NetworkError {
            switch error {
            case .serverError(let code, _):
                if code == 404 || code == 403 {
                    mySubmission = nil
                } else {
                    errorMessage = errorMessage ?? "Не удалось загрузить решение"
                }
            default:
                errorMessage = errorMessage ?? "Не удалось загрузить решение"
            }
        } catch {
            errorMessage = errorMessage ?? "Не удалось загрузить решение"
        }
    }

    private func loadGrade() async {
        guard let courseId = assignment?.courseId else { return }

        do {
            let grades = try await assignmentsRepository.getMyGrades(id: courseId)
            let uniqueGrades = Dictionary(
                grouping: grades,
                by: { $0.assignmentId }
            ).compactMap { $0.value.first }

            grade = uniqueGrades.first { $0.assignmentId == assignmentId }
        } catch {
            grade = nil
        }
    }

    private func resolveMyTeam() {
        guard let profileId = profile?.id else {
            myTeam = nil
            return
        }

        myTeam = assignmentTeams.first { team in
            let inMembers = team.members?.contains(where: { $0.userId == profileId }) ?? false
            let isCaptain = team.captain?.userId == profileId
            return inMembers || isCaptain
        }
    }

    private func mapTeamActionError(_ error: Error, fallback: String) -> String {
        guard let err = error as? NetworkError,
              case let .serverError(code, raw?) = err,
              let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            if let err = error as? NetworkError, case .serverError(let code, _) = err, code == 403 {
                return "Нет доступа"
            }
            return fallback
        }

        if let detail = obj["detail"] as? String, !detail.isEmpty, detail != "null" {
            return detail
        }

        if let title = obj["title"] as? String, !title.isEmpty {
            return title
        }

        if code == 403 {
            return "Нет доступа"
        }

        return fallback
    }
}
