import Foundation

struct GetSubmissionEndpoint: EndPoint {
    let assignmentId: String
    var baseURL: URL { APIConstants.baseURL }
    var path: String {
        APIConstants.Submissions.getSubmission(id: assignmentId)
    }
    var method: HTTPMethod { .get }
    var task: HTTPTask {
        .request
    }
    var authorization: AuthorizationRequirement { .accessToken }
}
