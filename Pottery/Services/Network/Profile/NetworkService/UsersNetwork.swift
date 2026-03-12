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
        let response = try await networkService.requestDecodable(endPoint, as: String.self)
        tokenStorage.accessToken = response
    }

    func getProfile() async throws -> ProfileResponse {
        let endPoint = GetProfileEndpoint()
        return try await networkService.requestDecodable(endPoint, as: ProfileResponse.self)
    }

    func editProfile(data: UpdateProfileRequest) async throws {
        let endPoint = UpdateProfile(bod)
        return try await networkService.requestDecodable(endPoint, as: UserResponse.self)
    }

    func deleteProfile() async throws {
        let endPoint = GetMyInfoEndPoint()
        return try await networkService.requestDecodable(endPoint, as: UserResponse.self)
    }
}
