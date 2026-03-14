import Foundation

final class SubmissionsNetwork: SubmissionsNetworkProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func uploadFiles(
        assignmentId: String,
        files: [MultipartFormData]
    ) async throws -> SubmissionResponse {

        let endpoint = UploadSubmissionFilesEndpoint(
            assignmentId: assignmentId,
            files: files
        )

        return try await networkService.requestDecodable(
            endpoint,
            as: SubmissionResponse.self
        )
    }

    func getSubmission(
        id: String
    ) async throws -> SubmissionResponse {

        let endpoint = GetSubmissionEndpoint(assignmentId: id)

        return try await networkService.requestDecodable(
            endpoint,
            as: SubmissionResponse.self
        )
    }

    func getMySubmission(
        assignmentId: String
    ) async throws -> SubmissionResponse? {

        let endpoint = GetMySubmissionEndpoint(
            assignmentId: assignmentId
        )

        return try await networkService.requestDecodable(
            endpoint,
            as: SubmissionResponse.self
        )
    }

    func deleteSubmissionFiles(
        submissionId: String,
        fileIds: [String]
    ) async throws {

        let endpoint = DeleteSubmissionFilesEndpoint(
            assignmentId: submissionId,
            fileIds: fileIds
        )

        try await networkService.request(endpoint)
    }
}
