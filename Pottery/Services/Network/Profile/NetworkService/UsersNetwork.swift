final class UsersNetwork: UsersNetworkProtocol {
    private let networkService: NetworkServiceProtocol
    private var tokenStorage: TokenStorageProtocol

    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }

    func register(data: RegisterRequest) async throws {
        let endPoint = RegisterEndpoint(body: data)
        _ = try await networkService.requestDecodable(endPoint, as: String.self)
    }

    func getProfile() async throws -> ProfileResponse {
        let endPoint = GetProfileEndpoint()
        return try await networkService.requestDecodable(endPoint, as: ProfileResponse.self)
    }

    func editProfile(data: UpdateProfileRequest) async throws {
        let endPoint = UpdateProfileEndpoint(body: data)
        try await networkService.request(endPoint)
    }

    func deleteProfile() async throws {
        let endPoint = DeleteProfileEndpoint()
        try await networkService.request(endPoint)
    }
}
