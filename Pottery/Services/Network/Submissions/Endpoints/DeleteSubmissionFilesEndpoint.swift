import Foundation

struct DeleteSubmissionFilesEndpoint: EndPoint {
    let assignmentId: String
    let fileIds: [String]

    var baseURL: URL { APIConstants.baseURL }
    var path: String {
        APIConstants.Submissions.deleteFiles(submissionId: assignmentId)
    }
    var method: HTTPMethod { .delete }
    var task: HTTPTask {
        .requestBody(fileIds)
    }
    var authorization: AuthorizationRequirement { .accessToken }
}
