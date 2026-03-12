import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let transport: NetworkTransport
    private let sessionService: SessionServiceProtocol

    init(
        networkTransport: NetworkTransport,
        sessionService: SessionServiceProtocol
    ) {
        self.transport = networkTransport
        self.sessionService = sessionService
    }

    func request(_ endpoint: EndPoint) async throws {
        NetworkLogger.log("➡️ [NetworkService] \(endpoint.method.rawValue) \(endpoint.baseURL)\(endpoint.path)")

        do {
            try await transport.send(endpoint)
            NetworkLogger.log("✅ [NetworkService] success")
        } catch NetworkError.unauthorized {
            NetworkLogger.log("⛔️ [NetworkService] 401 unauthorized -> logout()")
            sessionService.logout()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            throw NetworkError.unauthorized
        } catch {
            NetworkLogger.log("❌ [NetworkService] error: \(error)")
            throw error
        }
    }

    func requestDecodable<T: Decodable>(_ endpoint: EndPoint, as: T.Type) async throws -> T {
        NetworkLogger.log("➡️ [NetworkService] \(endpoint.method.rawValue) \(endpoint.baseURL)\(endpoint.path) -> decode \(T.self)")

        do {
            let result = try await transport.sendDecodable(endpoint, as: T.self)
            NetworkLogger.log("✅ [NetworkService] success decode \(T.self)")
            return result
        } catch NetworkError.unauthorized {
            NetworkLogger.log("⛔️ [NetworkService] 401 unauthorized -> logout()")
            sessionService.logout()
            throw NetworkError.unauthorized
        } catch {
            NetworkLogger.log("❌ [NetworkService] error: \(error)")
            throw error
        }
    }
}
