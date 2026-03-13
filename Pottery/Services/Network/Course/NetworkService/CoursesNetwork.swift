final class CoursesNetwork: CoursesNetworkProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func joinCourse(data: JoinCourseRequest) async throws -> CourseShortResponse {
        let endPoint = JoinCourseEndpoint(body: data)
        return try await networkService.requestDecodable(
            endPoint,
            as: CourseShortResponse.self
        )
    }

    func getMyCourses() async throws -> CoursesResponse {
        let endPoint = GetMyCoursesEndpoint()
        return try await networkService.requestDecodable(
            endPoint,
            as: CoursesResponse.self
        )
    }

    func getCourseInfo(id: String) async throws -> CourseShortResponse {
        let endPoint = GetCourseInfoEndpoint(id: id)
        return try await networkService.requestDecodable(
            endPoint,
            as: CourseShortResponse.self
        )
    }

    func leaveCourse(id: String) async throws {
        let endPoint = LeaveCourseEndpoint(id: id)
        try await networkService.request(endPoint)
    }

    func getCourseTeachers(id: String) async throws -> TeachersResponse {
        let endPoint = GetCourseTeachersEndpoint(id: id)
        return try await networkService.requestDecodable(
            endPoint,
            as: TeachersResponse.self
        )
    }
}
