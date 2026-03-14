struct SubmissionResponse: Decodable {

    let id: String
    let assignmentId: String
    let studentId: String
    let created: String
    let grade: Int?
    let status: String
    let files: [SubmissionFile]

}
