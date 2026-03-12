import XCTest
@testable import Pottery

final class MockUsersNetwork: UsersNetworkProtocol {

    var registerCalled = false
    var registerError: Error?

    var getProfileResult: Result<ProfileResponse, Error>?

    func register(data: RegisterRequest) async throws {
        registerCalled = true
        if let registerError { throw registerError }
    }

    func getProfile() async throws -> ProfileResponse {
        try getProfileResult!.get()
    }

    func editProfile(data: UpdateProfileRequest) async throws {}

    func deleteProfile() async throws {}
}
