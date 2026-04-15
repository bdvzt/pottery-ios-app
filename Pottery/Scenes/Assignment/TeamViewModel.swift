import Foundation
import Combine

@MainActor
final class TeamViewModel: ObservableObject {
    @Published var teams: [AssignmentTeam] = []
    @Published var captainMyTeam: CaptainMyTeamResponse?
    @Published var captainContext: CaptainAssignmentContextResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var finalSelectionErrorMessage: String?
    @Published var isSelectingFinalSubmission = false

    private let assignmentId: String
    private let assignmentsRepository: AssignmentsNetworkProtocol
    private var teamFormationMode: String?

    init(
        assignmentId: String,
        assignmentsRepository: AssignmentsNetworkProtocol,
        initialTeamFormationMode: String?
    ) {
        self.assignmentId = assignmentId
        self.assignmentsRepository = assignmentsRepository
        self.teamFormationMode = initialTeamFormationMode
    }

    var canShowFinalSubmissionPicker: Bool {
        captainContext?.isCaptain == true && captainMyTeam != nil
    }

    var canSelectFinalSubmissionNow: Bool {
        captainContext?.canSelectFinalSubmission == true
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        finalSelectionErrorMessage = nil
        defer { isLoading = false }

        do {
            if teamFormationMode == nil {
                let assignment = try await assignmentsRepository.getAssignment(id: assignmentId)
                teamFormationMode = assignment.normalizedTeamFormationMode
            }

            captainContext = try? await assignmentsRepository.getMyCaptainContext(assignmentId: assignmentId)
            teams = try await assignmentsRepository.getAssignmentTeams(assignmentId: assignmentId)

            if captainContext?.isCaptain == true {
                captainMyTeam = try? await assignmentsRepository.getCaptainMyTeam(assignmentId: assignmentId)
            } else {
                captainMyTeam = nil
            }
        } catch let error as NetworkError {
            if case .serverError(let code, _) = error {
                if code == 403 {
                    errorMessage = "Нет доступа к составу команд"
                } else if code == 400 {
                    errorMessage = "Состав команд сейчас недоступен"
                } else {
                    errorMessage = "Не удалось загрузить состав команды"
                }
            } else {
                errorMessage = "Не удалось загрузить состав команды"
            }
        } catch {
            errorMessage = "Не удалось загрузить состав команды"
        }
    }

    func selectFinalSubmission(_ submissionId: String) async {
        guard canShowFinalSubmissionPicker, canSelectFinalSubmissionNow else { return }

        isSelectingFinalSubmission = true
        finalSelectionErrorMessage = nil
        defer { isSelectingFinalSubmission = false }

        do {
            try await assignmentsRepository.selectCaptainFinalSubmission(
                assignmentId: assignmentId,
                submissionId: submissionId
            )
            captainMyTeam = try await assignmentsRepository.getCaptainMyTeam(assignmentId: assignmentId)
        } catch let error as NetworkError {
            finalSelectionErrorMessage = mapFinalSelectionError(error)
        } catch {
            finalSelectionErrorMessage = "Не удалось выбрать финальное решение"
        }
    }

    private func mapFinalSelectionError(_ error: NetworkError) -> String {
        guard case .serverError(let code, _) = error else {
            return "Не удалось выбрать финальное решение"
        }

        switch code {
        case 403:
            return "Только капитан команды может выбрать финальное решение"
        case 404:
            return "Решение не найдено"
        case 400:
            return "Нельзя выбрать финальное решение: состав не зафиксирован, не требуется выбор финала или дедлайн прошел"
        default:
            return "Не удалось выбрать финальное решение"
        }
    }
}
