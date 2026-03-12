import Foundation

enum NetworkError: Error {
    case invalidURL
    case encodingFailed
    case noResponse
    case unauthorized
    case serverError(code: Int, message: String?)
    case decodingFailed
    case transportError(underlying: Error)
}

extension NetworkError {
    var statusCode: HTTPStatusCode? {
        guard case let .serverError(code, _) = self else { return nil }
        return HTTPStatusCode(code: code)
    }
}
