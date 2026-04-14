import Foundation
import Combine

@MainActor
final class CoursesViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isJoiningCourse = false
    @Published var joinErrorMessage: String?

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

    func joinCourse(code: String) async -> Bool {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCode.isEmpty else {
            joinErrorMessage = "Введите код курса"
            return false
        }

        isJoiningCourse = true
        joinErrorMessage = nil
        defer { isJoiningCourse = false }

        do {
            let joinedCourse = try await courseRepository.joinCourse(
                data: JoinCourseRequest(code: trimmedCode)
            )

            if !courses.contains(where: { $0.id == joinedCourse.id }) {
                courses.insert(
                    Course(
                        id: joinedCourse.id,
                        name: joinedCourse.name,
                        description: joinedCourse.description,
                        code: joinedCourse.code,
                        isActive: joinedCourse.isActive,
                        role: nil
                    ),
                    at: 0
                )
            }

            errorMessage = nil
            return true
        } catch {
            joinErrorMessage = "Не удалось присоединиться к курсу. Проверьте код и попробуйте снова."
            return false
        }
    }

    func clearJoinState() {
        joinErrorMessage = nil
    }
}
