import Foundation
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var middleName: String
    @Published var email: String

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let usersRepository: UsersNetworkProtocol
    private let authRepository: AuthNetworkProtocol
    private let onProfileUpdated: () -> Void
    private let onProfileDeleted: () -> Void

    init(
        profile: ProfileResponse,
        usersRepository: UsersNetworkProtocol,
        authRepository: AuthNetworkProtocol,
        onProfileUpdated: @escaping () -> Void,
        onProfileDeleted: @escaping () -> Void
    ) {
        self.firstName = profile.firstName ?? ""
        self.lastName = profile.lastName ?? ""
        self.middleName = profile.middleName ?? ""
        self.email = profile.email
        self.usersRepository = usersRepository
        self.authRepository = authRepository
        self.onProfileUpdated = onProfileUpdated
        self.onProfileDeleted = onProfileDeleted
    }

    func save() async {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMiddleName = middleName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedFirstName.isEmpty else {
            errorMessage = "Введите имя"
            return
        }

        guard !trimmedLastName.isEmpty else {
            errorMessage = "Введите фамилию"
            return
        }

        guard !trimmedMiddleName.isEmpty else {
            errorMessage = "Введите отчество"
            return
        }

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Введите email"
            return
        }

        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Введите корректный email"
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await usersRepository.editProfile(
                data: UpdateProfileRequest(
                    firstName: trimmedFirstName,
                    lastName: trimmedLastName,
                    middleName: trimmedMiddleName,
                    email: trimmedEmail,
                    password: nil
                )
            )

            onProfileUpdated()
        } catch {
            errorMessage = "Не удалось сохранить изменения"
        }
    }

    func deleteAccount() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await usersRepository.deleteProfile()

            do {
                try await authRepository.logout()
            } catch {

            }

            onProfileDeleted()
        } catch {
            errorMessage = "Не удалось удалить аккаунт"
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", pattern)
        return predicate.evaluate(with: email)
    }
}
