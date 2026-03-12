import XCTest
@testable import Pottery

final class MockAuthNetwork: AuthNetworkProtocol {

    var loginCalled = false
    var logoutCalled = false
    var loginError: Error?

    func login(data: LoginRequest) async throws {
        loginCalled = true
        if let loginError { throw loginError }
    }

    func logout() async throws {
        logoutCalled = true
    }
}
