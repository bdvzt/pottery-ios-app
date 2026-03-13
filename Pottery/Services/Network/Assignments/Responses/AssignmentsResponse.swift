struct AssignmentsResponse: Decodable {
    let items: [AssignmentResponse]
    let total: Int
    let page: Int
    let pageSize: Int
}
