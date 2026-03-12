protocol AuthNetworkProtocol {
    func login(data: LoginRequest) async throws
    func logout() async throws
}
