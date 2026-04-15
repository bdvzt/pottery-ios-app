import XCTest
@testable import Pottery

@MainActor
final class AuthViewModelTests: XCTestCase {

    private func makeVM(
        auth: MockAuthNetwork = MockAuthNetwork(),
        users: MockUsersNetwork = MockUsersNetwork(),
        onLoginSuccess: @escaping () -> Void = {},
        onOpenRegistration: @escaping () -> Void = {}
    ) -> AuthViewModel {
        AuthViewModel(
            authRepository: auth,
            usersRepository: users,
            onLoginSuccess: onLoginSuccess,
            onOpenRegistration: onOpenRegistration
        )
    }

    func test_login_withEmptyEmail_setsError() async {
        let repo = MockAuthNetwork()
        let vm = makeVM(auth: repo)

        vm.email = ""
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Введите email")
        XCTAssertFalse(repo.loginCalled)
    }

    func test_login_withInvalidEmail_setsError() async {
        let repo = MockAuthNetwork()
        let vm = makeVM(auth: repo)

        vm.email = "wrong"
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Введите корректный email")
    }

    func test_login_withEmptyPassword_setsError() async {
        let repo = MockAuthNetwork()
        let vm = makeVM(auth: repo)

        vm.email = "test@test.com"
        vm.password = ""

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Введите пароль")
    }

    func test_login_success_callsRepository() async {
        let repo = MockAuthNetwork()
        let vm = makeVM(auth: repo)

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertTrue(repo.loginCalled)
    }

    func test_login_success_triggersCallback() async {
        let repo = MockAuthNetwork()
        var called = false

        let vm = makeVM(auth: repo, onLoginSuccess: { called = true })

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertTrue(called)
    }

    func test_login_failure_setsError() async {
        let repo = MockAuthNetwork()
        repo.loginError = MockError.failure

        let vm = makeVM(auth: repo)

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Не удалось войти")
    }

    func test_login_setsLoadingState() async {
        let repo = MockAuthNetwork()
        let vm = makeVM(auth: repo)

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertFalse(vm.isLoading)
    }

    func test_login_withNonStudentRole_showsWebMessageAndDoesNotCallSuccess() async {
        let auth = MockAuthNetwork()
        let users = MockUsersNetwork()
        users.getProfileResult = .success(
            ProfileResponse(
                id: "teacher-1",
                firstName: "Teacher",
                lastName: "User",
                middleName: nil,
                email: "teacher@test.com",
                role: .teacher
            )
        )

        var called = false
        let vm = makeVM(auth: auth, users: users, onLoginSuccess: { called = true })
        vm.email = "teacher@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Мобильное приложение доступно только для студентов. Используйте веб-версию.")
        XCTAssertTrue(auth.loginCalled)
        XCTAssertTrue(auth.logoutCalled)
        XCTAssertFalse(called)
    }
}
