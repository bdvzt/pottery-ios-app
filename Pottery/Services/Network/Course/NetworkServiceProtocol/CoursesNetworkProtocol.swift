protocol CoursesNetworkProtocol {
    func joinCourse(data: JoinCourseRequest) async throws -> CourseShortResponse
    func getMyCourses() async throws -> [Course]
    func getCourseInfo(id: String) async throws -> CourseShortResponse
    func leaveCourse(id: String) async throws
    func getCourseTeachers(id: String) async throws -> [Teacher]
}
