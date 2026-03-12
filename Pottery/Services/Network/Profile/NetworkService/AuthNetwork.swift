final class AuthNetwork: AuthNetworkProtocol {
    private let networkService: NetworkServiceProtocol
    private var tokenStorage: TokenStorageProtocol

    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }

    func login(data: LoginRequest) async throws {
        let endPoint = LoginEndPoint(body: data)
        let response = try await networkService.requestDecodable(endPoint, as: TokenResponse.self)
        tokenStorage.accessToken = response.token
    }

    func logout() async throws {
        let endPoint = LogoutEndPoint()
        try await networkService.request(endPoint)
        tokenStorage.accessToken = nil
    }
}
