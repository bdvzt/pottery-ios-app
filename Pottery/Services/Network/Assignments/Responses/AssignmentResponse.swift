struct AssignmentResponse: Decodable {
    let id: String
    let courseId: String
    let title: String?
    let text: String?
    let requiresSubmission: Bool
    let deadline: String?
    let created: String
    let files: [AssignmentFile]?
}
