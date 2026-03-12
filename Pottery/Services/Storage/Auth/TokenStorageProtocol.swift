protocol TokenStorageProtocol {
    var accessToken: String? { get set }

    func clear()
}
