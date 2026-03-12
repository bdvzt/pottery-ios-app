import Foundation
import Security

final class KeychainStore: KeyValueStoreProtocol {
    private let service: String
    private let accessGroup: String?
    private let accessibility: CFString

    init(
        service: String,
        accessGroup: String? = nil,
        accessibility: CFString = kSecAttrAccessibleAfterFirstUnlock
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.accessibility = accessibility
    }

    func set(_ data: Data, for key: String) throws {
        var query: [String: Any] = baseQuery(for: key)

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility,
        ]

        let exists = SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
        let status: OSStatus

        if exists {
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
        else {
            query.merge(attributes, uniquingKeysWith: { $1 })
            status = SecItemAdd(query as CFDictionary, nil)
        }

        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    func get(for key: String) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var out: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &out)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }

        return out as? Data
    }

    func delete(for key: String) throws {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}

private extension KeychainStore {
    func baseQuery(for key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }

        return query
    }
}
