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

    // MARK: - Courses
    enum Courses {
        static let joinCourse = "/api/courses/join"
        static let getMyCourses = "/api/courses/my?filter=Student"
        static func getCourseInfo(id: String) -> String {
            "/api/courses/\(id)"
        }
        static func leaveCourse(id: String) -> String {
            "/api/courses/\(id)/leave"
        }
        static func teachers(id: String) -> String {
            "/api/courses/\(id)/teachers"
        }
    }
}
