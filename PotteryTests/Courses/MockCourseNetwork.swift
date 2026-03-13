import XCTest
@testable import Pottery

final class MockCoursesNetwork: CoursesNetworkProtocol {
    var getCoursesResult: Result<CoursesResponse, Error> =
        .success(CoursesResponse(courses: []))

    var getCourseInfoResult: Result<CourseShortResponse, Error> =
        .failure(NSError())

    var getTeachersResult: Result<TeachersResponse, Error> =
        .success(TeachersResponse(teachers: []))

    var leaveCourseResult: Result<Void, Error> = .success(())

    func joinCourse(data: JoinCourseRequest) async throws -> CourseShortResponse {
        fatalError()
    }

    func getMyCourses() async throws -> CoursesResponse {
        try getCoursesResult.get()
    }

    func getCourseInfo(id: String) async throws -> CourseShortResponse {
        try getCourseInfoResult.get()
    }

    func leaveCourse(id: String) async throws {
        try leaveCourseResult.get()
    }

    func getCourseTeachers(id: String) async throws -> TeachersResponse {
        try getTeachersResult.get()
    }
}
