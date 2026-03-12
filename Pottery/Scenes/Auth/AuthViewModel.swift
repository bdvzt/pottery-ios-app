import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepository: AuthNetworkProtocol
    private let onLoginSuccess: () -> Void
    private let onOpenRegistration: () -> Void

    init(
        authRepository: AuthNetworkProtocol,
        onLoginSuccess: @escaping () -> Void,
        onOpenRegistration: @escaping () -> Void
    ) {
        self.authRepository = authRepository
        self.onLoginSuccess = onLoginSuccess
        self.onOpenRegistration = onOpenRegistration
    }

    func login() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Введите email"
            return
        }

        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Введите корректный email"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Введите пароль"
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await authRepository.login(
                data: LoginRequest(
                    email: trimmedEmail,
                    password: password
                )
            )

            onLoginSuccess()

        } catch {
            errorMessage = "Не удалось войти"
        }
    }

    func openRegistration() {
        onOpenRegistration()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}
