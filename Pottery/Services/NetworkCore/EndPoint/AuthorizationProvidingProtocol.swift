import Foundation

protocol AuthorizationProvidingProtocol: AnyObject {
    func addAuthorization(
        to request: URLRequest,
        requirement: AuthorizationRequirement
    ) async -> URLRequest
}
