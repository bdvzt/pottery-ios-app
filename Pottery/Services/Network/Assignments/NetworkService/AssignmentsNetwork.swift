final class AssignmentsNetwork: AssignmentsNetworkProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse] {
        let endPoint = GetCourseAssignmentsEndpoint(id: id, page: page, pageSize: pageSize)

        let response = try await networkService.requestDecodable(
            endPoint,
            as: AssignmentsResponse.self
        )

        return response.items
    }

    func getAssignment(id: String) async throws -> AssignmentResponse {
        let endPoint = GetAssignmentEndpoint(id: id)
        return try await networkService.requestDecodable(
            endPoint,
            as: AssignmentResponse.self
        )
    }
}
