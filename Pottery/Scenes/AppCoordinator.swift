import UIKit
import SwiftUI

final class AppCoordinator: Coordinator {

    let navigationController: NavigationController

    private let authNetwork: AuthNetworkProtocol
    private let usersNetwork: UsersNetworkProtocol

    init(
        navigationController: NavigationController,
        authNetwork: AuthNetworkProtocol,
        usersNetwork: UsersNetworkProtocol
    ) {
        self.navigationController = navigationController
        self.authNetwork = authNetwork
        self.usersNetwork = usersNetwork
    }

    func start() {
        showLogin()
    }
}