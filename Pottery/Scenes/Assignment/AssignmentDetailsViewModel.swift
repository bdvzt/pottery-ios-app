import Foundation
import Combine

@MainActor
final class AssignmentDetailsViewModel: ObservableObject {
    @Published var assignment: AssignmentResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let assignmentId: String
    private let assignmentsRepository: AssignmentsNetworkProtocol

    init(
        assignmentId: String,
        assignmentsRepository: AssignmentsNetworkProtocol
    ) {
        self.assignmentId = assignmentId
        self.assignmentsRepository = assignmentsRepository
    }

    func loadAssignment() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            assignment = try await assignmentsRepository.getAssignment(id: assignmentId)
        } catch {
            errorMessage = "Не удалось загрузить задание"
        }
    }
}
