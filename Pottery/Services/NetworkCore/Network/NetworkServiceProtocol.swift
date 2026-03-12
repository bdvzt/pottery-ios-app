import Foundation

protocol NetworkServiceProtocol {
    func request(_ endpoint: EndPoint) async throws
    func requestDecodable<T: Decodable>(_ endpoint: EndPoint, as type: T.Type) async throws -> T
}
