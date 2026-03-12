enum HTTPStatusCode: Int {
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204

    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case conflict = 409

    case internalServerError = 500
    case badGateway = 502
    case serviceUnavailable = 503

    case unknown

    static func isSuccess(_ code: Int) -> Bool {
        (200...299).contains(code)
    }

    init(code: Int) {
        self = HTTPStatusCode(rawValue: code) ?? .unknown
    }
}
