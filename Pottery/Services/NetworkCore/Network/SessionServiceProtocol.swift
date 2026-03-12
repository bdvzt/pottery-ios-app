protocol SessionServiceProtocol: AnyObject {
    func logout()
    func setOnLogout(_ action: @escaping () -> Void)
}
