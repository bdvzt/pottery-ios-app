import Foundation
import Combine

@MainActor
final class PeerReviewViewModel: ObservableObject {
    @Published var form: PeerReviewMyForm?
    @Published var status: PeerReviewPersonalStatus?
    @Published var drafts: [String: PeerReviewRatingDraft] = [:]
    @Published var expandedItemIds: Set<String> = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let assignmentId: String
    private let assignmentsRepository: AssignmentsNetworkProtocol

    init(
        assignmentId: String,
        assignmentsRepository: AssignmentsNetworkProtocol
    ) {
        self.assignmentId = assignmentId
        self.assignmentsRepository = assignmentsRepository
    }

    var items: [PeerReviewFormItem] {
        form?.items ?? []
    }

    var hasChanges: Bool {
        drafts.values.contains(where: \.hasChanged)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            async let formRequest = assignmentsRepository.getPeerReviewMyForm(assignmentId: assignmentId)
            async let statusRequest = assignmentsRepository.getPeerReviewMyStatus(assignmentId: assignmentId)

            let loadedForm = try await formRequest
            form = loadedForm
            status = try? await statusRequest
            buildDrafts(from: loadedForm)
        } catch {
            form = nil
            errorMessage = mapPeerReviewError(error, fallback: "Не удалось загрузить peer review")
        }
    }

    func toggleExpanded(_ item: PeerReviewFormItem) {
        if expandedItemIds.contains(item.id) {
            expandedItemIds.remove(item.id)
        } else {
            expandedItemIds.insert(item.id)
        }
    }

    func bindingForScore(submissionId: String) -> String {
        drafts[submissionId]?.scoreText ?? ""
    }

    func bindingForComment(submissionId: String) -> String {
        drafts[submissionId]?.comment ?? ""
    }

    func updateScore(submissionId: String, value: String) {
        guard var draft = drafts[submissionId] else { return }
        draft.scoreText = value
        drafts[submissionId] = draft
    }

    func updateComment(submissionId: String, value: String) {
        guard var draft = drafts[submissionId] else { return }
        draft.comment = String(value.prefix(4000))
        drafts[submissionId] = draft
    }

    func save() async {
        errorMessage = nil
        successMessage = nil

        guard form?.isReadOnly != true else {
            errorMessage = "Редактирование peer review сейчас недоступно."
            return
        }

        let validation = validateChangedRatings()
        guard validation.isEmpty else {
            errorMessage = validation.joined(separator: "\n")
            return
        }

        let ratings = changedRatingRequests()
        guard !ratings.isEmpty else {
            successMessage = "Нет изменений для сохранения."
            return
        }

        var seenSubmissionIds: Set<String> = []
        let uniqueRatings = ratings.filter { rating in
            seenSubmissionIds.insert(rating.submissionId).inserted
        }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await assignmentsRepository.savePeerReviewRatings(
                assignmentId: assignmentId,
                ratings: uniqueRatings
            )
            successMessage = "Оценки сохранены."
            await load()
        } catch {
            errorMessage = mapPeerReviewError(error, fallback: "Не удалось сохранить оценки peer review")
        }
    }

    private func buildDrafts(from form: PeerReviewMyForm) {
        var next: [String: PeerReviewRatingDraft] = [:]

        for item in form.items ?? [] {
            for submission in submissions(in: item) {
                next[submission.id] = PeerReviewRatingDraft(
                    peerReviewAssignmentId: item.peerReviewAssignmentId,
                    submissionId: submission.id,
                    originalScore: submission.score,
                    originalComment: normalizedComment(submission.comment),
                    scoreText: GradeFormatting.calculatedGradeText(submission.score) ?? "",
                    comment: normalizedComment(submission.comment) ?? ""
                )
            }
        }

        drafts = next
    }

    private func submissions(in item: PeerReviewFormItem) -> [PeerReviewSubmission] {
        var result: [PeerReviewSubmission] = []
        if let final = item.finalSubmission {
            result.append(final)
        }
        for member in item.memberSubmissions ?? [] {
            result.append(contentsOf: member.submissions ?? [])
        }
        return result
    }

    private func changedRatingRequests() -> [PeerReviewRatingRequest] {
        drafts.values.compactMap { draft in
            guard draft.hasChanged else { return nil }
            guard let score = parseScore(draft.scoreText) else { return nil }
            return PeerReviewRatingRequest(
                peerReviewAssignmentId: draft.peerReviewAssignmentId,
                submissionId: draft.submissionId,
                score: score,
                comment: normalizedComment(draft.comment)
            )
        }
    }

    private func validateChangedRatings() -> [String] {
        drafts.values.compactMap { draft in
            guard draft.hasChanged else { return nil }

            let trimmedScore = draft.scoreText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedScore.isEmpty, let score = parseScore(trimmedScore) else {
                return "Укажите оценку от 0 до 100."
            }

            guard score >= 0 && score <= 100 else {
                return "Оценка должна быть в диапазоне 0...100."
            }

            if draft.comment.count > 4000 {
                return "Комментарий не должен превышать 4000 символов."
            }

            return nil
        }
    }

    private func parseScore(_ raw: String) -> Decimal? {
        let normalized = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    private func normalizedComment(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func mapPeerReviewError(_ error: Error, fallback: String) -> String {
        guard let networkError = error as? NetworkError else { return fallback }

        if case .unauthorized = networkError {
            return "Сессия истекла. Войдите снова."
        }

        guard case let .serverError(code, raw) = networkError else { return fallback }
        let message = serverMessage(from: raw)
        let lowered = message?.lowercased() ?? ""

        if code == 403 {
            return "Нет доступа к peer review."
        }
        if lowered.contains("not enabled") || lowered.contains("не включ") || lowered.contains("отключ") {
            return "Peer review для этого задания не включен."
        }
        if lowered.contains("not started") || lowered.contains("has not started") || lowered.contains("не нач") {
            return "Peer review еще не начался."
        }
        if lowered.contains("deadline") || lowered.contains("ended") || lowered.contains("expired") || lowered.contains("дедлайн") || lowered.contains("срок") {
            return "Дедлайн peer review уже прошел."
        }
        if lowered.contains("not generated") || lowered.contains("assignments are not generated") || lowered.contains("не сформ") || lowered.contains("не сгенер") {
            return "Назначения peer review еще не сформированы."
        }
        if code == 400 || code == 422 {
            return message ?? "Проверьте оценки и комментарии."
        }
        return message ?? fallback
    }

    private func serverMessage(from raw: String?) -> String? {
        guard let raw,
              let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return raw
        }

        for key in ["message", "detail", "title", "code"] {
            if let value = obj[key] as? String, !value.isEmpty, value != "null" {
                return value
            }
        }

        if let errors = obj["errors"] as? [String: Any] {
            let messages = errors.values.flatMap { value -> [String] in
                if let strings = value as? [String] { return strings }
                if let string = value as? String { return [string] }
                return []
            }
            if !messages.isEmpty {
                return messages.joined(separator: "\n")
            }
        }

        if let details = obj["details"] as? [String] {
            return details.joined(separator: "\n")
        }

        return nil
    }
}

struct PeerReviewRatingDraft: Equatable {
    let peerReviewAssignmentId: String
    let submissionId: String
    let originalScore: Decimal?
    let originalComment: String?
    var scoreText: String
    var comment: String

    var hasChanged: Bool {
        let normalizedOriginalScore = GradeFormatting.calculatedGradeText(originalScore) ?? ""
        let normalizedOriginalComment = originalComment ?? ""
        return scoreText.trimmingCharacters(in: .whitespacesAndNewlines) != normalizedOriginalScore
            || comment.trimmingCharacters(in: .whitespacesAndNewlines) != normalizedOriginalComment
    }
}
