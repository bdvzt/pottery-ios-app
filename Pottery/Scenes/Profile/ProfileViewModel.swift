import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let usersRepository: UsersNetworkProtocol
    private let authRepository: AuthNetworkProtocol
    private let onLogout: () -> Void
    private let onEditProfile: (ProfileResponse) -> Void

    init(
        usersRepository: UsersNetworkProtocol,
        authRepository: AuthNetworkProtocol,
        onLogout: @escaping () -> Void,
        onEditProfile: @escaping (ProfileResponse) -> Void
    ) {
        self.usersRepository = usersRepository
        self.authRepository = authRepository
        self.onLogout = onLogout
        self.onEditProfile = onEditProfile
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await usersRepository.getProfile()
        } catch {
            errorMessage = "Не удалось загрузить профиль"
        }
    }

    func logout() async {
        do {
            try await authRepository.logout()
        } catch {
        }

        onLogout()
    }

    func openEditProfile() {
        guard let profile else { return }
        onEditProfile(profile)
    }
}
