import XCTest
@testable import Pottery

final class MockAssignmentsNetwork: AssignmentsNetworkProtocol {
    var getGradesResult: Result<[Grade], Error> = .success([])
    var getMyTeamGradeResult: Result<Grade, Error> = .success(
        Grade(assignmentId: "", assignmentTitle: nil, grade: nil)
    )
    var getAssignmentsResult: Result<[AssignmentResponse], Error> = .success([])
    var getAssignmentResult: Result<AssignmentResponse, Error> = .failure(TestError.mock)
    var getTeamsResult: Result<[AssignmentTeam], Error> = .success([])
    var createTeamResult: Result<AssignmentTeam, Error> = .failure(TestError.mock)
    var getCaptainContextResult: Result<CaptainAssignmentContextResponse, Error> = .success(
        CaptainAssignmentContextResponse(
            assignmentId: "",
            isCaptain: false,
            teamId: nil,
            finalSubmissionId: nil,
            canSelectFinalSubmission: false
        )
    )
    var getCaptainsResult: Result<[AssignmentCaptainListItem], Error> = .success([])
    var selfAssignCaptainResult: Result<Void, Error> = .success(())
    var withdrawCaptainResult: Result<Void, Error> = .success(())
    var getDraftStateResult: Result<AssignmentDraftStateResponse, Error> = .success(
        AssignmentDraftStateResponse(
            assignmentId: nil,
            isStarted: false,
            isCompleted: false,
            currentCaptainUserId: nil,
            teams: [],
            availableStudents: []
        )
    )
    var pickDraftStudentResult: Result<AssignmentDraftStateResponse, Error> = .success(
        AssignmentDraftStateResponse(
            assignmentId: nil,
            isStarted: false,
            isCompleted: false,
            currentCaptainUserId: nil,
            teams: [],
            availableStudents: []
        )
    )
    var captainMyTeamResult: Result<CaptainMyTeamResponse, Error> = .success(
        CaptainMyTeamResponse(
            id: "",
            assignmentId: nil,
            captain: nil,
            finalSubmissionId: nil,
            name: nil,
            members: []
        )
    )
    var selectFinalSubmissionResult: Result<Void, Error> = .success(())
    var gradingRulesResult: Result<AssignmentGradingRulesDto, Error> = .failure(TestError.mock)
    var criterionGroupsResult: Result<[CriterionGroupDto], Error> = .success([])
    var criteriaInGroupResult: Result<[CriterionDto], Error> = .success([])
    var peerReviewStatusResult: Result<PeerReviewPersonalStatus, Error> = .success(
        PeerReviewPersonalStatus(
            assignmentId: "",
            totalCount: 0,
            completedCount: 0,
            remainingCount: 0,
            isCompleted: false
        )
    )
    var peerReviewTeamStatusResult: Result<PeerReviewTeamStatus, Error> = .failure(TestError.mock)
    var peerReviewFormResult: Result<PeerReviewMyForm, Error> = .failure(TestError.mock)
    var savePeerReviewRatingsResult: Result<[PeerReviewRating], Error> = .success([])

    func getCourseAssignments(id: String, page: Int, pageSize: Int) async throws -> [AssignmentResponse] {
        try getAssignmentsResult.get()
    }

    func getAssignment(id: String) async throws -> AssignmentResponse {
        try getAssignmentResult.get()
    }

    func getMyGrades(id: String) async throws -> [Grade] {
        try getGradesResult.get()
    }

    func getMyTeamGrade(assignmentId: String) async throws -> Grade {
        try getMyTeamGradeResult.get()
    }

    func getAssignmentTeams(assignmentId: String) async throws -> [AssignmentTeam] {
        try getTeamsResult.get()
    }

    func createAssignmentTeam(assignmentId: String, name: String?) async throws -> AssignmentTeam {
        try createTeamResult.get()
    }

    func joinAssignmentTeam(teamId: String) async throws {}

    func leaveAssignmentTeam(teamId: String) async throws {}

    func getMyCaptainContext(assignmentId: String) async throws -> CaptainAssignmentContextResponse {
        try getCaptainContextResult.get()
    }

    func getAssignmentCaptains(assignmentId: String) async throws -> [AssignmentCaptainListItem] {
        try getCaptainsResult.get()
    }

    func selfAssignCaptain(assignmentId: String) async throws {
        try selfAssignCaptainResult.get()
    }

    func withdrawSelfAsCaptain(assignmentId: String) async throws {
        try withdrawCaptainResult.get()
    }

    func getAssignmentDraftState(assignmentId: String) async throws -> AssignmentDraftStateResponse {
        try getDraftStateResult.get()
    }

    func pickDraftStudent(assignmentId: String, studentId: String) async throws -> AssignmentDraftStateResponse {
        try pickDraftStudentResult.get()
    }

    func getCaptainMyTeam(assignmentId: String) async throws -> CaptainMyTeamResponse {
        try captainMyTeamResult.get()
    }

    func selectCaptainFinalSubmission(assignmentId: String, submissionId: String) async throws {
        try selectFinalSubmissionResult.get()
    }

    func getGradingRules(assignmentId: String) async throws -> AssignmentGradingRulesDto {
        try gradingRulesResult.get()
    }

    func getCriterionGroups(assignmentId: String) async throws -> [CriterionGroupDto] {
        try criterionGroupsResult.get()
    }

    func getCriteriaInGroup(groupId: String) async throws -> [CriterionDto] {
        try criteriaInGroupResult.get()
    }

    func getPeerReviewMyStatus(assignmentId: String) async throws -> PeerReviewPersonalStatus {
        try peerReviewStatusResult.get()
    }

    func getPeerReviewTeamStatus(assignmentId: String) async throws -> PeerReviewTeamStatus {
        try peerReviewTeamStatusResult.get()
    }

    func getPeerReviewMyForm(assignmentId: String) async throws -> PeerReviewMyForm {
        try peerReviewFormResult.get()
    }

    func savePeerReviewRatings(
        assignmentId: String,
        ratings: [PeerReviewRatingRequest]
    ) async throws -> [PeerReviewRating] {
        try savePeerReviewRatingsResult.get()
    }
}
