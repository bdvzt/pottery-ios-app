import Foundation

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

    func getMyGrades(id: String) async throws -> [Grade] {
        let endPoint = GetMyGradesEndpoint(id: id)
        return try await networkService.requestDecodable(
            endPoint,
            as: [Grade].self
        )
    }

    func getAssignmentTeams(assignmentId: String) async throws -> [AssignmentTeam] {
        let endPoint = GetAssignmentTeamsEndpoint(assignmentId: assignmentId)
        return try await networkService.requestDecodable(
            endPoint,
            as: [AssignmentTeam].self
        )
    }

    func createAssignmentTeam(assignmentId: String, name: String?) async throws -> AssignmentTeam {
        let endPoint = CreateAssignmentTeamEndpoint(
            assignmentId: assignmentId,
            body: CreateAssignmentTeamRequest(name: name)
        )
        return try await networkService.requestDecodable(
            endPoint,
            as: AssignmentTeam.self
        )
    }

    func joinAssignmentTeam(teamId: String) async throws {
        let endPoint = JoinAssignmentTeamEndpoint(teamId: teamId)
        try await networkService.request(endPoint)
    }

    func leaveAssignmentTeam(teamId: String) async throws {
        let endPoint = LeaveAssignmentTeamEndpoint(teamId: teamId)
        try await networkService.request(endPoint)
    }
}

private struct GetAssignmentTeamsEndpoint: EndPoint {
    private let assignmentId: String

    init(assignmentId: String) {
        self.assignmentId = assignmentId
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Assignments.teams(assignmentId: assignmentId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

private struct CreateAssignmentTeamEndpoint: EndPoint {
    private let assignmentId: String
    private let body: CreateAssignmentTeamRequest

    init(assignmentId: String, body: CreateAssignmentTeamRequest) {
        self.assignmentId = assignmentId
        self.body = body
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Assignments.createTeam(assignmentId: assignmentId) }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}

private struct JoinAssignmentTeamEndpoint: EndPoint {
    private let teamId: String

    init(teamId: String) {
        self.teamId = teamId
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Assignments.joinTeamSelf(teamId: teamId) }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

private struct LeaveAssignmentTeamEndpoint: EndPoint {
    private let teamId: String

    init(teamId: String) {
        self.teamId = teamId
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Assignments.leaveTeamSelf(teamId: teamId) }
    var method: HTTPMethod { .delete }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

private struct CreateAssignmentTeamRequest: Encodable {
    let name: String?
}
