struct AssignmentsResponse: Decodable {
    let items: [AssignmentResponse]
    let totalCount: Int?

    private enum CodingKeys: String, CodingKey {
        case items
        case totalCount
    }
}
