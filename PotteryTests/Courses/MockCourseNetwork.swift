import XCTest
@testable import Pottery

final class MockCoursesNetwork: CoursesNetworkProtocol {
    var getCoursesResult: Result<[Course], Error> =
        .success([])

    var getCourseInfoResult: Result<CourseShortResponse, Error> =
        .failure(NSError())

    var getTeachersResult: Result<[Teacher], Error> =
        .success([])

    var leaveCourseResult: Result<Void, Error> = .success(())

    func joinCourse(data: JoinCourseRequest) async throws -> CourseShortResponse {
        fatalError()
    }

    func getMyCourses() async throws -> [Course] {
        try getCoursesResult.get()
    }

    func getCourseInfo(id: String) async throws -> CourseShortResponse {
        try getCourseInfoResult.get()
    }

    func leaveCourse(id: String) async throws {
        try leaveCourseResult.get()
    }

    func getCourseTeachers(id: String) async throws -> [Teacher] {
        try getTeachersResult.get()
    }
}
