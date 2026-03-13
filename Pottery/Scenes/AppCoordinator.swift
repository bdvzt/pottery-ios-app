import UIKit
import SwiftUI

final class AppCoordinator: Coordinator {

    let navigationController: NavigationController

    private let authNetwork: AuthNetworkProtocol
    private let usersNetwork: UsersNetworkProtocol
    private let coursesNetwork: CoursesNetworkProtocol
    private let assignmentsNetwork: AssignmentsNetworkProtocol
    private let tokenStorage: TokenStorageProtocol

    init(
        navigationController: NavigationController,
        authNetwork: AuthNetworkProtocol,
        usersNetwork: UsersNetworkProtocol,
        coursesNetwork: CoursesNetworkProtocol,
        assignmentsNetwork: AssignmentsNetworkProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.navigationController = navigationController
        self.authNetwork = authNetwork
        self.usersNetwork = usersNetwork
        self.coursesNetwork = coursesNetwork
        self.assignmentsNetwork = assignmentsNetwork
        self.tokenStorage = tokenStorage
    }

    func start() {
        if tokenStorage.accessToken != nil {
            showMainTabs()
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
                self?.showMainTabs()
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

    func showMainTabs() {
        let tabBarController = UITabBarController()

        // MARK: Courses

        let coursesNavigation = NavigationController()

        let coursesViewModel = CoursesViewModel(
            courseRepository: coursesNetwork,
            onOpenCourse: { [weak self] course in
                self?.showCourseDetails(course: course, navigation: coursesNavigation)
            }
        )

        let coursesView = CoursesView(viewModel: coursesViewModel)
        let coursesController = UIHostingController(rootView: coursesView)

        coursesNavigation.setViewControllers([coursesController], animated: false)

        coursesNavigation.tabBarItem = UITabBarItem(
            title: "Курсы",
            image: UIImage(systemName: "book"),
            tag: 0
        )

        // MARK: Profile

        let profileNavigation = NavigationController()

        let profileViewModel = ProfileViewModel(
            usersRepository: usersNetwork,
            authRepository: authNetwork,
            onLogout: { [weak self] in
                self?.showLogin()
            },
            onEditProfile: { [weak self] profile in
                self?.showEditProfile(profile: profile)
            }
        )

        let profileView = ProfileView(viewModel: profileViewModel)
        let profileController = UIHostingController(rootView: profileView)

        profileNavigation.setViewControllers([profileController], animated: false)

        profileNavigation.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person"),
            tag: 1
        )

        // MARK: TabBar

        tabBarController.viewControllers = [
            coursesNavigation,
            profileNavigation
        ]

        navigationController.setViewControllers([tabBarController], animated: true)
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

    func showCourseDetails(course: CourseShortResponse, navigation: UINavigationController) {
        let viewModel = CourseDetailsViewModel(
            courseId: course.id,
            courseRepository: coursesNetwork,
            onLeaveCourse: {
                navigation.popViewController(animated: true)
            }
        )

        let view = CourseDetailsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)

        navigation.pushViewController(controller, animated: true)
    }
}
