protocol UsersNetworkProtocol {
    func register(data: RegisterRequest) async throws
    func getProfile() async throws -> ProfileResponse
    func editProfile(data: UpdateProfileRequest) async throws
    func deleteProfile() async throws
}
