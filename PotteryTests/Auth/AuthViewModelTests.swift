import XCTest
@testable import Pottery

@MainActor
final class AuthViewModelTests: XCTestCase {

    func test_login_withEmptyEmail_setsError() async {
        let repo = MockAuthNetwork()
        let vm = AuthViewModel(authRepository: repo, onLoginSuccess: {}, onOpenRegistration: {})

        vm.email = ""
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Введите email")
        XCTAssertFalse(repo.loginCalled)
    }

    func test_login_withInvalidEmail_setsError() async {
        let repo = MockAuthNetwork()
        let vm = AuthViewModel(authRepository: repo, onLoginSuccess: {}, onOpenRegistration: {})

        vm.email = "wrong"
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Введите корректный email")
    }

    func test_login_withEmptyPassword_setsError() async {
        let repo = MockAuthNetwork()
        let vm = AuthViewModel(authRepository: repo, onLoginSuccess: {}, onOpenRegistration: {})

        vm.email = "test@test.com"
        vm.password = ""

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Введите пароль")
    }

    func test_login_success_callsRepository() async {
        let repo = MockAuthNetwork()
        let vm = AuthViewModel(authRepository: repo, onLoginSuccess: {}, onOpenRegistration: {})

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertTrue(repo.loginCalled)
    }

    func test_login_success_triggersCallback() async {
        let repo = MockAuthNetwork()
        var called = false

        let vm = AuthViewModel(
            authRepository: repo,
            onLoginSuccess: { called = true },
            onOpenRegistration: {}
        )

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertTrue(called)
    }

    func test_login_failure_setsError() async {
        let repo = MockAuthNetwork()
        repo.loginError = MockError.failure

        let vm = AuthViewModel(authRepository: repo, onLoginSuccess: {}, onOpenRegistration: {})

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertEqual(vm.errorMessage, "Не удалось войти")
    }

    func test_login_setsLoadingState() async {
        let repo = MockAuthNetwork()
        let vm = AuthViewModel(authRepository: repo, onLoginSuccess: {}, onOpenRegistration: {})

        vm.email = "test@test.com"
        vm.password = "123"

        await vm.login()

        XCTAssertFalse(vm.isLoading)
    }
}
