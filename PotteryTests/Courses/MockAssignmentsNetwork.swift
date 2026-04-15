import XCTest
@testable import Pottery

final class MockAssignmentsNetwork: AssignmentsNetworkProtocol {
    var getGradesResult: Result<[Grade], Error> = .success([])
    var getAssignmentsResult: Result<[AssignmentResponse], Error> = .success([])
    var getAssignmentResult: Result<AssignmentResponse, Error> = .failure(TestError.mock)
    var getTeamsResult: Result<[AssignmentTeam], Error> = .success([])
    var createTeamResult: Result<AssignmentTeam, Error> = .failure(TestError.mock)

    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse] {
        try getAssignmentsResult.get()
    }

    func getAssignment(id: String) async throws -> AssignmentResponse {
        try getAssignmentResult.get()
    }

    func getMyGrades(id: String) async throws -> [Grade] {
        try getGradesResult.get()
    }

    func getAssignmentTeams(assignmentId: String) async throws -> [AssignmentTeam] {
        try getTeamsResult.get()
    }

    func createAssignmentTeam(assignmentId: String, name: String?) async throws -> AssignmentTeam {
        try createTeamResult.get()
    }

    func joinAssignmentTeam(teamId: String) async throws {}

    func leaveAssignmentTeam(teamId: String) async throws {}
}
