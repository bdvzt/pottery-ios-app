import Foundation

public protocol KeyValueStoreProtocol {
    func set(_ data: Data, for key: String) throws
    func get(for key: String) throws -> Data?
    func delete(for key: String) throws
}
