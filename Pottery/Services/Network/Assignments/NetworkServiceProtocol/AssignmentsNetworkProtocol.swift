protocol AssignmentsNetworkProtocol {
    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse]
    func getAssignment(id: String) async throws -> AssignmentResponse
    func getMyGrades(id: String) async throws -> [Grade]
    func getAssignmentTeams(assignmentId: String) async throws -> [AssignmentTeam]
    func createAssignmentTeam(assignmentId: String, name: String?) async throws -> AssignmentTeam
    func joinAssignmentTeam(teamId: String) async throws
    func leaveAssignmentTeam(teamId: String) async throws
    func getMyCaptainContext(assignmentId: String) async throws -> CaptainAssignmentContextResponse
    func getAssignmentCaptains(assignmentId: String) async throws -> [AssignmentCaptainListItem]
    func selfAssignCaptain(assignmentId: String) async throws
    func withdrawSelfAsCaptain(assignmentId: String) async throws
}
