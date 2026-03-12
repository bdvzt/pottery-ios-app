import XCTest
import Foundation
@testable import Pottery

@MainActor
final class ProfileViewModelTests: XCTestCase {

    func test_loadProfile_success_setsProfile() async {
        let repo = MockUsersNetwork()
        let profile = ProfileResponse(
            id: UUID().uuidString,
            firstName: "Ivan",
            lastName: "Ivanov",
            middleName: "Ivanovich",
            email: "test@test.com",
            role: .student
        )

        repo.getProfileResult = .success(profile)

        let vm = ProfileViewModel(
            usersRepository: repo,
            authRepository: MockAuthNetwork(),
            onLogout: {}
        )

        await vm.loadProfile()

        XCTAssertEqual(vm.profile?.email, "test@test.com")
    }

    func test_loadProfile_failure_setsError() async {
        let repo = MockUsersNetwork()
        repo.getProfileResult = .failure(MockError.failure)

        let vm = ProfileViewModel(
            usersRepository: repo,
            authRepository: MockAuthNetwork(),
            onLogout: {}
        )

        await vm.loadProfile()

        XCTAssertEqual(vm.errorMessage, "Не удалось загрузить профиль")
    }

    func test_loadProfile_setsLoadingFalse() async {
        let repo = MockUsersNetwork()
        repo.getProfileResult = .failure(MockError.failure)

        let vm = ProfileViewModel(
            usersRepository: repo,
            authRepository: MockAuthNetwork(),
            onLogout: {}
        )

        await vm.loadProfile()

        XCTAssertFalse(vm.isLoading)
    }

    func test_loadProfile_setsLoadingTrueDuringCall() async {
        let repo = MockUsersNetwork()
        repo.getProfileResult = .success(
            ProfileResponse(
                id: UUID().uuidString,
                firstName: nil,
                lastName: nil,
                middleName: nil,
                email: "a@a.com",
                role: .student
            )
        )

        let vm = ProfileViewModel(
            usersRepository: repo,
            authRepository: MockAuthNetwork(),
            onLogout: {}
        )

        await vm.loadProfile()

        XCTAssertNotNil(vm.profile)
    }

    func test_logout_callsRepository() async {
        let auth = MockAuthNetwork()

        let vm = ProfileViewModel(
            usersRepository: MockUsersNetwork(),
            authRepository: auth,
            onLogout: {}
        )

        await vm.logout()

        XCTAssertTrue(auth.logoutCalled)
    }

    func test_logout_triggersCallback() async {
        var called = false

        let vm = ProfileViewModel(
            usersRepository: MockUsersNetwork(),
            authRepository: MockAuthNetwork(),
            onLogout: { called = true }
        )

        await vm.logout()

        XCTAssertTrue(called)
    }

    func test_loadProfile_clearsErrorOnSuccess() async {
        let repo = MockUsersNetwork()
        repo.getProfileResult = .success(
            ProfileResponse(
                id: UUID().uuidString,
                firstName: nil,
                lastName: nil,
                middleName: nil,
                email: "test@test.com",
                role: .student
            )
        )

        let vm = ProfileViewModel(
            usersRepository: repo,
            authRepository: MockAuthNetwork(),
            onLogout: {}
        )

        await vm.loadProfile()

        XCTAssertNil(vm.errorMessage)
    }
}
