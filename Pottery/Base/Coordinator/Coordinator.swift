import UIKit

protocol Coordinator: AnyObject {
    var navigationController: NavigationController { get }

    func start()
}
