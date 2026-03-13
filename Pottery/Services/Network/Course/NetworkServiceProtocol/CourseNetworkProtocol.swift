protocol CourseNetworkProtocol {
    func joinCourse(data: JoinCourseRequest) async throws -> CourseShortResponse
    func getMyCourses() async throws -> CoursesResponse
    func getCourseInfo(id: String) async throws -> CourseShortResponse
    func leaveCourse(id: String) async throws
    func getCourseTeachers(id: String) async throws -> TeachersResponse
}
