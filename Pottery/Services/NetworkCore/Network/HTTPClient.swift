import Foundation

final class HTTPClient: NetworkTransport {
    private let session: URLSession
    private let authorizationProvider: AuthorizationProvidingProtocol
    
    init(
        session: URLSession = .shared,
        authorizationProvider: AuthorizationProvidingProtocol
    ) {
        self.session = session
        self.authorizationProvider = authorizationProvider
    }
    
    func send(_ endpoint: EndPoint) async throws -> Data {
        var request = try URLRequestBuilder.build(from: endpoint)
        request = await authorizationProvider.addAuthorization(
            to: request,
            requirement: endpoint.authorization
        )
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.noResponse
            }
            
            if HTTPStatusCode.isSuccess(http.statusCode) {
                return data
            }
            
            if http.statusCode == HTTPStatusCode.unauthorized.rawValue {
                throw NetworkError.unauthorized
            }
            
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(code: http.statusCode, message: message)
        }
        catch let error as NetworkError {
            throw error
        }
        catch {
            throw NetworkError.transportError(underlying: error)
        }
    }
    
    func sendDecodable<T: Decodable>(_ endpoint: EndPoint, as: T.Type) async throws -> T {
        let data = try await send(endpoint)
        
        if let json = String(data: data, encoding: .utf8) {
            print("📦 RAW JSON:", json)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            throw NetworkError.decodingFailed
        }
    }
}
