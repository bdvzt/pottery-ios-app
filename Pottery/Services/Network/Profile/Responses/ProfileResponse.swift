struct ProfileResponse: Decodable {
    let id: String
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let email: String
    let role: Role
}
