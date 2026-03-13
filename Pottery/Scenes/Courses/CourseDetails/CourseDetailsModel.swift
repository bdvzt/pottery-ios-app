import Foundation
import Combine

@MainActor
final class CourseDetailsViewModel: ObservableObject {
    @Published var course: CourseShortResponse?
    @Published var teachers: [Teacher] = []
    @Published var assignments: [AssignmentResponse] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let courseId: String
    private let courseNetwork: CoursesNetworkProtocol
    private let assignmentsNetwork: AssignmentsNetworkProtocol

    private let onLeaveCourse: () -> Void
    private let onOpenAssignment: (AssignmentResponse) -> Void

    init(
        courseId: String,
        courseNetwork: CoursesNetworkProtocol,
        assignmentsNetwork: AssignmentsNetworkProtocol,
        onLeaveCourse: @escaping () -> Void,
        onOpenAssignment: @escaping (AssignmentResponse) -> Void
    ) {
        self.courseId = courseId
        self.courseNetwork = courseNetwork
        self.assignmentsNetwork = assignmentsNetwork
        self.onLeaveCourse = onLeaveCourse
        self.onOpenAssignment = onOpenAssignment
    }

    func loadCourse() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let courseRequest = courseNetwork.getCourseInfo(id: courseId)
            async let teachersRequest = courseNetwork.getCourseTeachers(id: courseId)
            async let assignmentsRequest = assignmentsNetwork.getCourseAssignments(
                id: courseId,
                page: 1,
                pageSize: 20
            )

            course = try await courseRequest
            teachers = try await teachersRequest
            assignments = try await assignmentsRequest

        } catch {
            errorMessage = "Не удалось загрузить курс"
        }
    }

    func openAssignment(_ assignment: AssignmentResponse) {
        onOpenAssignment(assignment)
    }

    func leaveCourse() async {
        do {
            try await courseNetwork.leaveCourse(id: courseId)
            onLeaveCourse()
        } catch {
            errorMessage = "Не удалось покинуть курс"
        }
    }
}
