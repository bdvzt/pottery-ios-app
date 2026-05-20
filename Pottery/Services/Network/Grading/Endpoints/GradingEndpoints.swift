import Foundation

struct GetGradingRulesEndpoint: EndPoint {
    let assignmentId: String
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Assignments.gradingRules(assignmentId: assignmentId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

struct GetCriterionGroupsEndpoint: EndPoint {
    let assignmentId: String
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Assignments.criterionGroups(assignmentId: assignmentId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

struct GetCriteriaInGroupEndpoint: EndPoint {
    let groupId: String
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Criteria.criteriaInGroup(groupId: groupId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

struct GetSubmissionAssessmentEndpoint: EndPoint {
    let submissionId: String
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Submissions.assessment(submissionId: submissionId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
