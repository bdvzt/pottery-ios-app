struct Comment: Decodable {
    let id: String
    let assignmentId: String
    let userId: String
    let userName: String?
    let text: String?
    let created: String
}
