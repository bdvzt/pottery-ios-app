struct RegisterRequest: Encodable {
    let firstName: String
    let lastName: String
    let middleName: String?
    let email: String
    let password: String
}
