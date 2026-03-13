protocol AssignmentsNetworkProtocol {
    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse]
    func getAssignment(id: String) async throws -> AssignmentResponse
    func getMyGrades(id: String) async throws -> [Grade]
}
