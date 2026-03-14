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
        static let getMyCourses = "/api/courses/my"
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

    // MARK: - Assignments
    enum Assignments {
        static func getAssignment(id: String) -> String {
            "/api/assignments/\(id)"
        }
        static func getCourseAssignments(id: String) -> String {
            "/api/courses/\(id)/assignments"
        }
        static func myGrades(id: String) -> String {
            "/api/courses/\(id)/my-grades"
        }
    }

    // MARK: - Comments
    enum Comments {
        static func assignmentComment(id: String) -> String {
            "/api/assignments/\(id)/comments"
        }
        static func editComment(id: String) -> String {
            "/api/assignments/comments/\(id)"
        }
    }

    // MARK: - Submissions
    enum Submissions {
        static func uploadFiles(assignmentId: String) -> String {
            "/api/submissions/\(assignmentId)/files"
        }
        static func deleteFiles(submissionId: String) -> String {
            "/api/submissions/\(submissionId)/files"
        }
        static func getSubmission(id: String) -> String {
            "/api/submissions/\(id)"
        }
        static func getMySubmission(assignmentId: String) -> String {
            "/assignments/\(assignmentId)/my-submission"
        }
    }
}
