protocol AssignmentsNetworkProtocol {
    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse]
    func getAssignment(id: String) async throws -> AssignmentResponse
    func getMyGrades(id: String) async throws -> [Grade]
    func getMyTeamGrade(assignmentId: String) async throws -> Grade
    func getAssignmentTeams(assignmentId: String) async throws -> [AssignmentTeam]
    func createAssignmentTeam(assignmentId: String, name: String?) async throws -> AssignmentTeam
    func joinAssignmentTeam(teamId: String) async throws
    func leaveAssignmentTeam(teamId: String) async throws
    func getMyCaptainContext(assignmentId: String) async throws -> CaptainAssignmentContextResponse
    func getAssignmentCaptains(assignmentId: String) async throws -> [AssignmentCaptainListItem]
    func selfAssignCaptain(assignmentId: String) async throws
    func withdrawSelfAsCaptain(assignmentId: String) async throws
    func getAssignmentDraftState(assignmentId: String) async throws -> AssignmentDraftStateResponse
    func pickDraftStudent(assignmentId: String, studentId: String) async throws -> AssignmentDraftStateResponse
    func getCaptainMyTeam(assignmentId: String) async throws -> CaptainMyTeamResponse
    func selectCaptainFinalSubmission(assignmentId: String, submissionId: String) async throws
    func getGradingRules(assignmentId: String) async throws -> AssignmentGradingRulesDto
    func getCriterionGroups(assignmentId: String) async throws -> [CriterionGroupDto]
    func getCriteriaInGroup(groupId: String) async throws -> [CriterionDto]
    func getPeerReviewMyStatus(assignmentId: String) async throws -> PeerReviewPersonalStatus
    func getPeerReviewTeamStatus(assignmentId: String) async throws -> PeerReviewTeamStatus
    func getPeerReviewMyForm(assignmentId: String) async throws -> PeerReviewMyForm
    func savePeerReviewRatings(assignmentId: String, ratings: [PeerReviewRatingRequest]) async throws -> [PeerReviewRating]
}
