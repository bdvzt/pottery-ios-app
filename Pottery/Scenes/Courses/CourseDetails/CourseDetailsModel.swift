import Foundation
import Combine

@MainActor
final class CourseDetailsViewModel: ObservableObject {
    @Published var course: CourseShortResponse?
    @Published var teachers: [Teacher] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let courseId: String
    private let courseRepository: CoursesNetworkProtocol
    private let onLeaveCourse: () -> Void

    init(
        courseId: String,
        courseRepository: CoursesNetworkProtocol,
        onLeaveCourse: @escaping () -> Void
    ) {
        self.courseId = courseId
        self.courseRepository = courseRepository
        self.onLeaveCourse = onLeaveCourse
    }

    func loadCourse() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            course = try await courseRepository.getCourseInfo(id: courseId)
            let teachersResponse = try await courseRepository.getCourseTeachers(id: courseId)
            teachers = teachersResponse
        } catch {
            errorMessage = "Не удалось загрузить курс"
        }
    }

    func leaveCourse() async {
        do {
            try await courseRepository.leaveCourse(id: courseId)
            onLeaveCourse()
        } catch {
            errorMessage = "Не удалось покинуть курс"
        }
    }
}
