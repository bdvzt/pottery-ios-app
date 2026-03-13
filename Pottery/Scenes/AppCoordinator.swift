import UIKit
import SwiftUI

final class AppCoordinator: Coordinator {

    let navigationController: NavigationController

    private let authNetwork: AuthNetworkProtocol
    private let usersNetwork: UsersNetworkProtocol
    private let coursesNetwork: CoursesNetworkProtocol
    private let tokenStorage: TokenStorageProtocol

    init(
        navigationController: NavigationController,
        authNetwork: AuthNetworkProtocol,
        usersNetwork: UsersNetworkProtocol,
        coursesNetwork: CoursesNetworkProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.navigationController = navigationController
        self.authNetwork = authNetwork
        self.usersNetwork = usersNetwork
        self.coursesNetwork = coursesNetwork
        self.tokenStorage = tokenStorage
    }

    func start() {
        if tokenStorage.accessToken != nil {
            showProfile()
        } else {
            showLogin()
        }
    }
}

private extension AppCoordinator {
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func showLogin() {
        let viewModel = AuthViewModel(
            authRepository: authNetwork,
            onLoginSuccess: { [weak self] in
                self?.showProfile()
            },
            onOpenRegistration: { [weak self] in
                self?.showRegistration()
            }
        )

        let view = AuthView(viewModel: viewModel)

        let controller = UIHostingController(rootView: view)

        navigationController.setViewControllers([controller], animated: false)
    }

    func showRegistration() {
        let viewModel = RegistrationViewModel(
            usersRepository: usersNetwork,
            onRegistrationSuccess: { [weak self] in
                self?.showLogin()
            },
            onBackToLogin: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        )

        let view = RegistrationView(viewModel: viewModel)

        let controller = UIHostingController(rootView: view)

        navigationController.pushViewController(controller, animated: true)
    }

    func showProfile() {
        let viewModel = ProfileViewModel(
            usersRepository: usersNetwork,
            authRepository: authNetwork,
            onLogout: { [weak self] in
                self?.showLogin()
            },
            onEditProfile: { [weak self] profile in
                self?.showEditProfile(profile: profile)
            }
        )

        let view = ProfileView(viewModel: viewModel)

        let controller = UIHostingController(rootView: view)

        navigationController.setViewControllers([controller], animated: true)
    }

    func showEditProfile(profile: ProfileResponse) {
        let viewModel = EditProfileViewModel(
            profile: profile,
            usersRepository: usersNetwork,
            authRepository: authNetwork,
            onProfileUpdated: { [weak self] in
                self?.back()
            },
            onProfileDeleted: { [weak self] in
                self?.showLogin()
            }
        )

        let view = EditProfileView(viewModel: viewModel)

        let controller = UIHostingController(rootView: view)

        navigationController.pushViewController(controller, animated: true)
    }
}
