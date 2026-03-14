import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = NavigationController()

        let tokenStorage = KeychainTokenStorage()
        let authorizationProvider = AuthorizationProvider(tokenStorage: tokenStorage)
        let networkTransport = HTTPClient(authorizationProvider: authorizationProvider)
        let sessionService = SessionService(tokenStorage: tokenStorage)
        let networkService = NetworkService(
            networkTransport: networkTransport,
            sessionService: sessionService
        )

        let authNetwork = AuthNetwork(
            networkService: networkService,
            tokenStorage: tokenStorage
        )

        let usersNetwork = UsersNetwork(
            networkService: networkService,
            tokenStorage: tokenStorage
        )

        let coursesNetwork = CoursesNetwork(
            networkService: networkService
        )

        let assignmentsNetwork = AssignmentsNetwork(
            networkService: networkService
        )

        let commentsNetwork = CommentsNetwork(
            networkService: networkService
        )

        let submissionsRepository = SubmissionsNetwork(
            networkService: networkService
        )

        coordinator = AppCoordinator(
            navigationController: navigationController,
            authNetwork: authNetwork,
            usersNetwork: usersNetwork,
            coursesNetwork: coursesNetwork,
            assignmentsNetwork: assignmentsNetwork,
            commentsNetwork: commentsNetwork,
            submissionsRepository: submissionsRepository,
            tokenStorage: tokenStorage
        )

        coordinator?.start()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

