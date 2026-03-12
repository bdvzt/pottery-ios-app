import XCTest
@testable import Pottery

@MainActor
final class RegistrationViewModelTests: XCTestCase {

    func makeVM(repo: MockUsersNetwork = MockUsersNetwork()) -> RegistrationViewModel {
        RegistrationViewModel(
            usersRepository: repo,
            onRegistrationSuccess: {},
            onBackToLogin: {}
        )
    }

    func test_register_emptyFirstName_setsError() async {
        let vm = makeVM()

        vm.firstName = ""
        await vm.register()

        XCTAssertEqual(vm.errorMessage, "Введите имя")
    }

    func test_register_emptyLastName_setsError() async {
        let vm = makeVM()

        vm.firstName = "Ivan"
        vm.lastName = ""

        await vm.register()

        XCTAssertEqual(vm.errorMessage, "Введите фамилию")
    }

    func test_register_emptyMiddleName_setsError() async {
        let vm = makeVM()

        vm.firstName = "Ivan"
        vm.lastName = "Ivanov"
        vm.middleName = ""

        await vm.register()

        XCTAssertEqual(vm.errorMessage, "Введите отчество")
    }

    func test_register_emptyEmail_setsError() async {
        let vm = makeVM()

        vm.firstName = "Ivan"
        vm.lastName = "Ivanov"
        vm.middleName = "Ivanovich"
        vm.email = ""

        await vm.register()

        XCTAssertEqual(vm.errorMessage, "Введите email")
    }

    func test_register_invalidEmail_setsError() async {
        let vm = makeVM()

        vm.firstName = "Ivan"
        vm.lastName = "Ivanov"
        vm.middleName = "Ivanovich"
        vm.email = "wrong"

        await vm.register()

        XCTAssertEqual(vm.errorMessage, "Введите корректный email")
    }

    func test_register_emptyPassword_setsError() async {
        let vm = makeVM()

        vm.firstName = "Ivan"
        vm.lastName = "Ivanov"
        vm.middleName = "Ivanovich"
        vm.email = "test@test.com"
        vm.password = ""

        await vm.register()

        XCTAssertEqual(vm.errorMessage, "Введите пароль")
    }

    func test_register_success_callsRepository() async {
        let repo = MockUsersNetwork()

        let vm = RegistrationViewModel(
            usersRepository: repo,
            onRegistrationSuccess: {},
            onBackToLogin: {}
        )

        vm.firstName = "Ivan"
        vm.lastName = "Ivanov"
        vm.middleName = "Ivanovich"
        vm.email = "test@test.com"
        vm.password = "123"

        await vm.register()

        XCTAssertTrue(repo.registerCalled)
    }
}
