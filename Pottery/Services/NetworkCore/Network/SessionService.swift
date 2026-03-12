import Foundation

final class SessionService: SessionServiceProtocol {
    private var tokenStorage: TokenStorageProtocol
    private var onLogout: (() -> Void)?

    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }

    func setOnLogout(_ action: @escaping () -> Void) {
        self.onLogout = action
    }

    func logout() {
        tokenStorage.clear()
        onLogout?()
    }
}
