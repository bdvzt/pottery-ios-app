import Foundation

final class AuthorizationProvider: AuthorizationProvidingProtocol {
    private let tokenStorage: TokenStorageProtocol

    init(
        tokenStorage: TokenStorageProtocol
    ) {
        self.tokenStorage = tokenStorage
    }

    func addAuthorization(
        to request: URLRequest,
        requirement: AuthorizationRequirement
    ) async -> URLRequest {
        switch requirement {
        case .none:
            return request

        case .accessToken:
            guard let token = tokenStorage.accessToken,
                token.isEmpty == false
            else {
                return request
            }
            return requestAddingBearer(token, to: request)
        }
    }
}

extension AuthorizationProvider {
    func requestAddingBearer(_ token: String, to request: URLRequest) -> URLRequest {
        var modified = request
        modified.setValue(
            "\(HTTPHeaderValue.bearerPrefix) \(token)",
            forHTTPHeaderField: HTTPHeader.authorization
        )
        return modified
    }
}
