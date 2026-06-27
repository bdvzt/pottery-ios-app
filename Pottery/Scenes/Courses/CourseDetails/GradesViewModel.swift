import Foundation
import Combine

@MainActor
final class GradesViewModel: ObservableObject {
    @Published var grades: [Grade] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let courseId: String
    private let assignmentsNetwork: AssignmentsNetworkProtocol

    init(courseId: String, assignmentsNetwork: AssignmentsNetworkProtocol) {
        self.courseId = courseId
        self.assignmentsNetwork = assignmentsNetwork
    }

    func loadGrades() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await assignmentsNetwork.getMyGrades(id: courseId)
            var uniqueByAssignmentId: [String: Grade] = [:]
            for item in response {
                if let existing = uniqueByAssignmentId[item.assignmentId] {
                    if existing.grade == nil, item.grade != nil {
                        uniqueByAssignmentId[item.assignmentId] = item
                    }
                } else {
                    uniqueByAssignmentId[item.assignmentId] = item
                }
            }

            grades = Array(uniqueByAssignmentId.values)
                .sorted { ($0.assignmentTitle ?? "") < ($1.assignmentTitle ?? "") }
        } catch let error as NetworkError {
            if case .serverError(let code, _) = error, code == 403 {
                errorMessage = "Нет доступа к оценкам"
            } else {
                errorMessage = "Не удалось загрузить оценки"
            }
        } catch {
            errorMessage = "Не удалось загрузить оценки"
        }
    }
}
