import Foundation

struct UploadSubmissionFilesEndpoint: EndPoint {
    let assignmentId: String
    let files: [MultipartFormData]

    var baseURL: URL { APIConstants.baseURL }
    var path: String {
        APIConstants.Submissions.uploadFiles(assignmentId: assignmentId)
    }
    var method: HTTPMethod { .post }
    var task: HTTPTask {
        .uploadMultipart(files)
    }
    var authorization: AuthorizationRequirement { .accessToken }
}
