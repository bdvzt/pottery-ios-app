import Foundation

struct GetMySubmissionEndpoint: EndPoint {
    let assignmentId: String
    var baseURL: URL { APIConstants.baseURL }
    var path: String {
        APIConstants.Submissions.getMySubmission(assignmentId: assignmentId)
    }
    var method: HTTPMethod { .get }
    var task: HTTPTask {
        .request
    }
    var authorization: AuthorizationRequirement { .accessToken }
}
