import UIKit

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        setNavigationBarHidden(false, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
