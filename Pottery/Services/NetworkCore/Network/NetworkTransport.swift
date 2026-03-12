import Foundation

protocol NetworkTransport {
    @discardableResult
    func send(_ endpoint: EndPoint) async throws -> Data

    func sendDecodable<T: Decodable>(_ endpoint: EndPoint, as: T.Type) async throws -> T
}
