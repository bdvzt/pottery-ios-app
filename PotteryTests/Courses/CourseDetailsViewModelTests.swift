import XCTest
@testable import Pottery

enum TestError: Error {
    case mock
}

@MainActor
final class CourseDetailsViewModelTests: XCTestCase {

    func test_loadCourse_success_setsCourse() async {

        let coursesMock = MockCoursesNetwork()
        let assignmentsMock = MockAssignmentsNetwork()

        let course = CourseShortResponse(
            id: "course-1",
            name: "iOS Development",
            description: "Swift",
            code: "IOS101",
            isActive: true
        )

        coursesMock.getCourseInfoResult = .success(course)

        let viewModel = CourseDetailsViewModel(
            courseId: "course-1",
            courseNetwork: coursesMock,
            assignmentsNetwork: assignmentsMock,
            onLeaveCourse: {},
            onOpenAssignment: { _ in }
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.course?.id, "course-1")
    }


    func test_loadCourse_success_setsTeachers() async {

        let coursesMock = MockCoursesNetwork()
        let assignmentsMock = MockAssignmentsNetwork()

        coursesMock.getCourseInfoResult = .success(
            CourseShortResponse(
                id: "course-1",
                name: "iOS",
                description: nil,
                code: nil,
                isActive: true
            )
        )

        coursesMock.getTeachersResult = .success([
            Teacher(
                id: "teacher-1",
                firstName: "Иван",
                lastName: "Иванов",
                email: "teacher@test.com"
            )
        ])

        let viewModel = CourseDetailsViewModel(
            courseId: "course-1",
            courseNetwork: coursesMock,
            assignmentsNetwork: assignmentsMock,
            onLeaveCourse: {},
            onOpenAssignment: { _ in }
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.teachers.count, 1)
    }


    func test_loadCourse_success_setsAssignments() async {

        let coursesMock = MockCoursesNetwork()
        let assignmentsMock = MockAssignmentsNetwork()

        coursesMock.getCourseInfoResult = .success(
            CourseShortResponse(
                id: "course-1",
                name: "iOS",
                description: nil,
                code: nil,
                isActive: true
            )
        )

        assignmentsMock.getAssignmentsResult = .success([
            AssignmentResponse(
                id: "assignment-1",
                courseId: "course-1",
                title: "Homework",
                text: nil,
                requiresSubmission: true,
                deadline: nil,
                created: "2024-01-01",
                files: nil
            )
        ])

        let viewModel = CourseDetailsViewModel(
            courseId: "course-1",
            courseNetwork: coursesMock,
            assignmentsNetwork: assignmentsMock,
            onLeaveCourse: {},
            onOpenAssignment: { _ in }
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.assignments.count, 1)
    }


    func test_loadCourse_failure_setsError() async {

        let coursesMock = MockCoursesNetwork()
        let assignmentsMock = MockAssignmentsNetwork()

        coursesMock.getCourseInfoResult = .failure(TestError.mock)

        let viewModel = CourseDetailsViewModel(
            courseId: "course-1",
            courseNetwork: coursesMock,
            assignmentsNetwork: assignmentsMock,
            onLeaveCourse: {},
            onOpenAssignment: { _ in }
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.errorMessage, "Не удалось загрузить курс")
    }


    func test_leaveCourse_success_callsCallback() async {

        let coursesMock = MockCoursesNetwork()
        let assignmentsMock = MockAssignmentsNetwork()

        var called = false

        let viewModel = CourseDetailsViewModel(
            courseId: "1",
            courseNetwork: coursesMock,
            assignmentsNetwork: assignmentsMock,
            onLeaveCourse: {
                called = true
            },
            onOpenAssignment: { _ in }
        )

        await viewModel.leaveCourse()

        XCTAssertTrue(called)
    }


    func test_leaveCourse_failure_setsError() async {

        let coursesMock = MockCoursesNetwork()
        let assignmentsMock = MockAssignmentsNetwork()

        coursesMock.leaveCourseResult = .failure(TestError.mock)

        let viewModel = CourseDetailsViewModel(
            courseId: "1",
            courseNetwork: coursesMock,
            assignmentsNetwork: assignmentsMock,
            onLeaveCourse: {},
            onOpenAssignment: { _ in }
        )

        await viewModel.leaveCourse()

        XCTAssertEqual(viewModel.errorMessage, "Не удалось покинуть курс")
    }
}
