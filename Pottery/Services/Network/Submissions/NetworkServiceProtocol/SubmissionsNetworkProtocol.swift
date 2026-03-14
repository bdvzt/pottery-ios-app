import Foundation

protocol SubmissionsNetworkProtocol {

    func uploadFiles(
        assignmentId: String,
        files: [MultipartFormData]
    ) async throws -> SubmissionResponse

    func getSubmission(
        id: String
    ) async throws -> SubmissionResponse

    func getMySubmission(
        assignmentId: String
    ) async throws -> SubmissionResponse?

    func deleteSubmissionFiles(
        submissionId: String,
        fileIds: [String]
    ) async throws
}
