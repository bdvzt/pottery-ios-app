import XCTest
@testable import Pottery

final class MockAssignmentsNetwork: AssignmentsNetworkProtocol {
    var getAssignmentsResult: Result<[AssignmentResponse], Error> = .success([])
    var getAssignmentResult: Result<AssignmentResponse, Error> = .failure(TestError.mock)

    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse] {
        try getAssignmentsResult.get()
    }

    func getAssignment(id: String) async throws -> AssignmentResponse {
        try getAssignmentResult.get()
    }
}
