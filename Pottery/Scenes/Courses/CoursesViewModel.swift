import Foundation
import Combine

@MainActor
final class CoursesViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let courseRepository: CoursesNetworkProtocol
    private let onOpenCourse: (CourseShortResponse) -> Void

    init(
        courseRepository: CoursesNetworkProtocol,
        onOpenCourse: @escaping (CourseShortResponse) -> Void
    ) {
        self.courseRepository = courseRepository
        self.onOpenCourse = onOpenCourse
    }

    func loadCourses() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await courseRepository.getMyCourses()
            courses = response
        } catch {
            errorMessage = "Не удалось загрузить курсы"
        }
    }

    func openCourse(_ course: CourseShortResponse) {
        onOpenCourse(course)
    }
}
