import Security

enum KeychainStoreFactory {
    static func make(
        service: String,
        accessGroup: String? = nil,
        accessibility: CFString = kSecAttrAccessibleAfterFirstUnlock
    ) -> KeyValueStoreProtocol {
        KeychainStore(
            service: service,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
    }
}
