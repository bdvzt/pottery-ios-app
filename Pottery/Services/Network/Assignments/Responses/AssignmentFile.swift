struct AssignmentFile: Decodable {
    let id: String
    let fileName: String
    let url: String?
    let mimeType: String?
    let size: Int64
}
