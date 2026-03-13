struct CourseShortResponse: Decodable {
    let id: String
    let name: String?
    let description: String?
    let code: String?
    let isActive: Bool
}
