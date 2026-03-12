import Foundation

enum APIConstants {
    // MARK: - Base URLs
    static let baseURL = URL(string: "http://localhost:5196")!

    // MARK: - Auth
    enum Auth {
        static let login = "/api/auth/login"
        static let logout = "/api/auth/logout"
    }

    // MARK: - Users
    enum Users {
        static let register = "/api/users"
        static let profile = "/api/users/me"
    }
}
