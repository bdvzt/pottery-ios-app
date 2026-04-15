import XCTest
@testable import Pottery

@MainActor
final class AssignmentDetailsViewModelTests: XCTestCase {

    func test_loadAssignment_success_setsAssignment() async {
        let assignmentsMock = MockAssignmentsNetwork()
        let usersMock = MockUsersNetwork()
        let submissionsMock = MockSubmissionsNetwork()

        let assignment = makeAssignmentResponse(id: "assignment-1", courseId: "course-1")

        assignmentsMock.getAssignmentResult = .success(assignment)

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            usersRepository: usersMock,
            submissionsRepository: submissionsMock
        )

        await viewModel.loadAssignment()

        XCTAssertEqual(viewModel.assignment?.id, "assignment-1")
    }

    func test_loadAssignment_success_setsGrade() async {
        let assignmentsMock = MockAssignmentsNetwork()
        let usersMock = MockUsersNetwork()
        let submissionsMock = MockSubmissionsNetwork()

        let assignment = makeAssignmentResponse(
            id: "assignment-1",
            courseId: "course-1"
        )
        assignmentsMock.getAssignmentResult = .success(assignment)

        assignmentsMock.getGradesResult = .success([
            Grade(
                assignmentId: "assignment-1",
                assignmentTitle: "Homework",
                grade: 5
            )
        ])

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            usersRepository: usersMock,
            submissionsRepository: submissionsMock
        )

        await viewModel.loadAssignment()

        XCTAssertEqual(viewModel.grade?.grade, 5)
    }

    private func makeAssignmentResponse(id: String, courseId: String) -> AssignmentResponse {
        AssignmentResponse(
            id: id,
            courseId: courseId,
            title: "Homework",
            text: "Do task",
            status: "available",
            startsAtUtc: nil,
            minTeamSize: nil,
            maxTeamSize: nil,
            teamFormationMode: nil,
            captainSelectionEndsAtUtc: nil,
            teamFormationStartsAtUtc: nil,
            teamFormationEndsAtUtc: nil,
            draftCurrentCaptainUserId: nil,
            draftStartedAtUtc: nil,
            draftCompletedAtUtc: nil,
            isTeamCompositionLocked: nil,
            teamCompositionLockedAtUtc: nil,
            isVisible: true,
            isClosed: false,
            requiresSubmission: false,
            deadline: nil,
            created: "2024-01-01",
            files: nil
        )
    }
}

private final class MockSubmissionsNetwork: SubmissionsNetworkProtocol {
    var getMySubmissionResult: Result<SubmissionResponse?, Error> = .success(nil)

    func uploadFiles(assignmentId: String, files: [MultipartFormData]) async throws -> SubmissionResponse {
        throw TestError.mock
    }

    func getSubmission(id: String) async throws -> SubmissionResponse {
        throw TestError.mock
    }

    func getMySubmission(assignmentId: String) async throws -> SubmissionResponse? {
        try getMySubmissionResult.get()
    }

    func deleteSubmissionFiles(submissionId: String, fileIds: [String]) async throws {}
}
