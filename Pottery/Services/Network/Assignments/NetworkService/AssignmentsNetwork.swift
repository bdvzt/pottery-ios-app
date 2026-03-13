final class AssignmentsNetwork: AssignmentsNetworkProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse] {
        let endPoint = GetCourseAssignmentsEndpoint(id: id, page: page, pageSize: pageSize)
        return try await networkService.requestDecodable(
            endPoint,
            as: [AssignmentResponse].self
        )
    }

    func getAssignment(id: String) async throws -> AssignmentResponse {
        let endPoint = GetAssignmentEndpoint(id: id)
        return try await networkService.requestDecodable(
            endPoint,
            as: AssignmentResponse.self
        )
    }
}
