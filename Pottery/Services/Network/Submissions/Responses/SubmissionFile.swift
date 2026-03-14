
struct SubmissionFile: Decodable {

    let id: String
    let fileName: String
    let url: String
    let mimeType: String
    let size: Int
    let type: String

}
struct AssignmentFile: Decodable, Identifiable {
    let id: String
    let fileName: String
    let url: String
    let mimeType: String
    let size: Int64
    let type: String
}
