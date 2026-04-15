import Foundation

enum APIConstants {
    // MARK: - Base URLs
    static let baseURL = URL(string: "http://111.88.155.34:5196")!

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
        static func getVisibleCourseAssignments(id: String) -> String {
            "/api/courses/\(id)/assignments/visible"
        }
        static func myGrades(id: String) -> String {
            "/api/courses/\(id)/my-grades"
        }
        static func teams(assignmentId: String) -> String {
            "/api/assignments/\(assignmentId)/teams"
        }
        static func createTeam(assignmentId: String) -> String {
            "/api/assignments/\(assignmentId)/teams"
        }
        static func joinTeamSelf(teamId: String) -> String {
            "/api/assignments/teams/\(teamId)/join-self"
        }
        static func leaveTeamSelf(teamId: String) -> String {
            "/api/assignments/teams/\(teamId)/leave-self"
        }
        static func assignmentCaptains(assignmentId: String) -> String {
            "/api/assignments/\(assignmentId)/captains"
        }
        static func assignmentCaptainMe(assignmentId: String) -> String {
            "/api/assignments/\(assignmentId)/captains/me"
        }
        static func assignmentCaptainSelf(assignmentId: String) -> String {
            "/api/assignments/\(assignmentId)/captains/self"
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
