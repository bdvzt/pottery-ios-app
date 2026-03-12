import Foundation

protocol ConfigurableCoordinator: Coordinator {
    associatedtype Configuration
    
    init(navigationController: NavigationController, configuration: Configuration)
}

extension ConfigurableCoordinator {
    init(navigationController: NavigationController) {
        fatalError("Use init with configuration for this coordinator")
    }
}
