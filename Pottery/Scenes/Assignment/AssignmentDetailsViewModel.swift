import Foundation
import Combine
import UniformTypeIdentifiers

@MainActor
final class AssignmentDetailsViewModel: ObservableObject {
    @Published var profile: ProfileResponse?

    @Published var pendingUploadFiles: [PendingSubmissionUploadFile] = []
    @Published var isSubmitting = false
    @Published var mySubmission: SubmissionResponse?
    @Published var selectedSubmissionFileIds: Set<String> = []

    @Published var assignment: AssignmentResponse?
    @Published var assignmentTeams: [AssignmentTeam] = []
    @Published var myTeam: AssignmentTeam?
    @Published var captainContext: CaptainAssignmentContextResponse?
    @Published private(set) var isVolunteerCaptain = false
    @Published var draftState: AssignmentDraftStateResponse?
    @Published var isDraftLoading = false
    @Published var draftErrorMessage: String?

    @Published var isLoading = false
    @Published var isUpdatingTeam = false
    @Published var errorMessage: String?
    @Published var teamErrorMessage: String?

    @Published var grade: Grade?

    private let assignmentId: String
    private let assignmentsRepository: AssignmentsNetworkProtocol
    private let usersRepository: UsersNetworkProtocol
    private let submissionsRepository: SubmissionsNetworkProtocol
    private var draftPollingTask: Task<Void, Never>?

    init(
        assignmentId: String,
        assignmentsRepository: AssignmentsNetworkProtocol,
        usersRepository: UsersNetworkProtocol,
        submissionsRepository: SubmissionsNetworkProtocol,
    ) {
        self.assignmentId = assignmentId
        self.assignmentsRepository = assignmentsRepository
        self.usersRepository = usersRepository
        self.submissionsRepository = submissionsRepository
    }

    deinit {
        draftPollingTask?.cancel()
    }

    func loadAssignment() async {
        isLoading = true
        errorMessage = nil
        teamErrorMessage = nil
        defer { isLoading = false }

        await loadProfile()

        await loadAssignmentDetails()
        guard assignment != nil, errorMessage == nil else { return }
        await reloadTeams()
        await loadCaptainState()
        await refreshDraftState()
        await loadSubmission()
        await loadGrade()
    }

    private func loadAssignmentDetails() async {
        do {
            let loaded = try await assignmentsRepository.getAssignment(id: assignmentId)
            if !loaded.isAvailableForStudentNow {
                assignment = nil
                errorMessage = "Задание пока недоступно"
                return
            }
            assignment = loaded
        } catch let error as NetworkError {
            switch error {
            case .serverError(let code, let message):
                if code == 403 {
                    if (message?.lowercased().contains("пока недоступно") == true) {
                        errorMessage = "Задание пока недоступно"
                    } else {
                        errorMessage = "Задание скрыто"
                    }
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
            await refreshDraftState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось вступить в команду")
        }
    }

    func createTeam(name: String) async {
        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        guard let assignment else { return }

        if assignment.normalizedTeamFormationMode == "captain_draft" {
            teamErrorMessage = "В режиме драфта команды формируются через выбор студентов капитанами."
            return
        }

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
            await refreshDraftState()
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
            await refreshDraftState()
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
            await refreshDraftState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось снять роль капитана")
        }
    }

    func leaveMyTeam() async {
        guard let team = myTeam else { return }
        if team.captain?.userId == profile?.id {
            teamErrorMessage = "Капитан не может выйти из своей команды."
            return
        }
        let teamId = team.id

        isUpdatingTeam = true
        teamErrorMessage = nil
        defer { isUpdatingTeam = false }

        do {
            try await assignmentsRepository.leaveAssignmentTeam(teamId: teamId)
            await reloadTeams()
            await loadCaptainState()
            await refreshDraftState()
        } catch {
            teamErrorMessage = mapTeamActionError(error, fallback: "Не удалось выйти из команды")
        }
    }

    var isCaptainDraftMode: Bool {
        assignment?.normalizedTeamFormationMode == "captain_draft"
    }

    var isMyDraftTurn: Bool {
        guard let profileId = profile?.id else { return false }
        return draftState?.currentCaptainUserId == profileId
    }

    func refreshDraftState() async {
        guard isCaptainDraftMode else {
            draftState = nil
            draftErrorMessage = nil
            stopDraftPolling()
            return
        }

        isDraftLoading = true
        defer { isDraftLoading = false }

        do {
            let state = try await assignmentsRepository.getAssignmentDraftState(assignmentId: assignmentId)
            draftState = state
            assignmentTeams = state.teams
            resolveMyTeam()
            draftErrorMessage = nil
            updateDraftPolling(with: state)
        } catch {
            draftErrorMessage = mapTeamActionError(error, fallback: "Не удалось загрузить драфт")
            stopDraftPolling()
        }
    }

    func pickDraftStudent(_ student: AssignmentDraftStudent) async {
        guard isCaptainDraftMode else { return }
        guard isMyDraftTurn else {
            draftErrorMessage = "Сейчас ход другого капитана."
            return
        }

        isUpdatingTeam = true
        draftErrorMessage = nil
        defer { isUpdatingTeam = false }

        do {
            let state = try await assignmentsRepository.pickDraftStudent(
                assignmentId: assignmentId,
                studentId: student.userId
            )
            draftState = state
            assignmentTeams = state.teams
            resolveMyTeam()
            await reloadTeams()
            updateDraftPolling(with: state)
        } catch {
            draftErrorMessage = mapTeamActionError(error, fallback: "Не удалось выбрать студента")
        }
    }

    func addPickedFiles(urls: [URL]) async {
        var picked: [PendingSubmissionUploadFile] = []

        for url in urls {
            let accessGranted = url.startAccessingSecurityScopedResource()
            defer {
                if accessGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let data = try Data(contentsOf: url)
                let fileName = url.lastPathComponent
                let mimeType = mimeType(for: url)
                picked.append(
                    PendingSubmissionUploadFile(
                        fileName: fileName,
                        mimeType: mimeType,
                        data: data
                    )
                )
            } catch {
                errorMessage = "Не удалось прочитать файл \(url.lastPathComponent)"
            }
        }

        pendingUploadFiles.append(contentsOf: picked)
    }

    func removePendingUploadFile(_ fileId: UUID) {
        pendingUploadFiles.removeAll { $0.id == fileId }
    }

    func clearPendingUploadFiles() {
        pendingUploadFiles.removeAll()
    }

    func submitSolution() async {

        guard !pendingUploadFiles.isEmpty else { return }
        if let assignment, !assignment.isSubmissionWindowOpen {
            errorMessage = "Сейчас отправка решения недоступна: задание еще не началось или дедлайн уже прошел."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {

            let files: [MultipartFormData] = pendingUploadFiles.map { file in
                MultipartFormData(
                    name: "files",
                    filename: file.fileName,
                    mimeType: file.mimeType,
                    data: file.data
                )
            }

            _ = try await submissionsRepository.uploadFiles(
                assignmentId: assignmentId,
                files: files
            )

            pendingUploadFiles.removeAll()

            await loadAssignment()

        } catch let error as NetworkError {
            switch error {
            case .serverError(let code, _):
                if code == 400 {
                    errorMessage = "Сейчас отправка решения недоступна: задание еще не началось или дедлайн уже прошел."
                } else if code == 403 {
                    errorMessage = "Нет доступа к отправке решения."
                } else {
                    errorMessage = "Не удалось отправить решение"
                }
            default:
                errorMessage = "Не удалось отправить решение"
            }
        } catch {
            errorMessage = "Не удалось отправить решение"
        }
    }

    func toggleSubmissionFileSelection(_ fileId: String) {
        if selectedSubmissionFileIds.contains(fileId) {
            selectedSubmissionFileIds.remove(fileId)
        } else {
            selectedSubmissionFileIds.insert(fileId)
        }
    }

    func clearSubmissionFileSelection() {
        selectedSubmissionFileIds.removeAll()
    }

    func deleteSelectedSubmissionFiles() async {
        guard let submission = mySubmission else { return }
        let fileIds = Array(selectedSubmissionFileIds)
        guard !fileIds.isEmpty else { return }

        do {
            try await submissionsRepository.deleteSubmissionFiles(
                submissionId: submission.id,
                fileIds: fileIds
            )
            selectedSubmissionFileIds.removeAll()
            await loadSubmission()
        } catch {
            errorMessage = "Не удалось удалить выбранные файлы"
        }
    }

    func makeTeamViewModel() -> TeamViewModel {
        TeamViewModel(
            assignmentId: assignmentId,
            assignmentsRepository: assignmentsRepository,
            initialTeamFormationMode: assignment?.normalizedTeamFormationMode
        )
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

    private func updateDraftPolling(with state: AssignmentDraftStateResponse) {
        if state.isStarted && !state.isCompleted {
            startDraftPolling()
        } else {
            stopDraftPolling()
        }
    }

    private func startDraftPolling() {
        guard draftPollingTask == nil else { return }
        draftPollingTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                guard self.isCaptainDraftMode else {
                    self.stopDraftPolling()
                    return
                }
                do {
                    let state = try await self.assignmentsRepository.getAssignmentDraftState(assignmentId: self.assignmentId)
                    self.draftState = state
                    self.assignmentTeams = state.teams
                    self.resolveMyTeam()
                    self.draftErrorMessage = nil
                    if !(state.isStarted && !state.isCompleted) {
                        self.stopDraftPolling()
                        return
                    }
                } catch {
                    self.draftErrorMessage = self.mapTeamActionError(error, fallback: "Не удалось обновить драфт")
                }
            }
        }
    }

    private func stopDraftPolling() {
        draftPollingTask?.cancel()
        draftPollingTask = nil
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
        if isCaptainDraftMode {
            assignmentTeams = draftState?.teams ?? []
            resolveMyTeam()
            return
        }

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

    private func loadSubmission() async {
        do {
            let submission = try await submissionsRepository.getMySubmission(
                assignmentId: assignmentId
            )

            mySubmission = submission
            selectedSubmissionFileIds.removeAll()
        } catch let error as NetworkError {
            switch error {
            case .serverError(let code, _):
                if code == 404 || code == 403 {
                    mySubmission = nil
                    selectedSubmissionFileIds.removeAll()
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
            return normalizeTeamErrorMessage(detail)
        }

        if let title = obj["title"] as? String, !title.isEmpty {
            return normalizeTeamErrorMessage(title)
        }

        if code == 403 {
            return "Нет доступа"
        }

        return fallback
    }

    private func normalizeTeamErrorMessage(_ message: String) -> String {
        let lowered = message.lowercased()
        let mentionsCaptainLimit =
            lowered.contains("капитан") &&
            (lowered.contains("лимит") || lowered.contains("слишком много") || lowered.contains("превыш"))

        if mentionsCaptainLimit {
            return "Достигнут лимит капитанов для этого задания. Вступите в существующую команду или дождитесь изменений от преподавателя."
        }

        return message
    }

    private func mimeType(for url: URL) -> String {
        let ext = url.pathExtension
        if let type = UTType(filenameExtension: ext),
           let mime = type.preferredMIMEType {
            return mime
        }
        return "application/octet-stream"
    }
}

struct PendingSubmissionUploadFile: Identifiable {
    let id = UUID()
    let fileName: String
    let mimeType: String
    let data: Data
}
