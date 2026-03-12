import UIKit

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private var popObservers: [NavigationPopObserver] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setNavigationBarHidden(true, animated: false)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addPopObserver(for viewController: UIViewController, coordinator: Coordinator) {
        let observer = NavigationPopObserver(observedViewController: viewController, coordinator: coordinator)
        popObservers.append(observer)
    }
    
    func removeAllPopObservers() {
        popObservers.removeAll()
    }
}

// MARK: - UINavigationControllerDelegate

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        popObservers.forEach { observer in
            if !navigationController.viewControllers.contains(observer.observedViewController) {
                observer.didObservePop()
                popObservers.removeAll { $0 === observer }
            }
        }
    }
}
