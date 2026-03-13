import XCTest
@testable import Pottery

enum TestError: Error {
    case mock
}

@MainActor
final class CourseDetailsViewModelTests: XCTestCase {

    func test_loadCourse_success_setsCourse() async {
        let mock = MockCoursesNetwork()

        let courseShort = CourseShortResponse(
            id: "course-1",
            name: "iOS Development",
            description: "Swift и UIKit",
            code: "IOS101",
            isActive: true
        )

        mock.getCourseInfoResult = .success(courseShort)

        let viewModel = CourseDetailsViewModel(
            courseId: "course-1",
            courseRepository: mock,
            onLeaveCourse: {}
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.course?.id, "course-1")
    }

    func test_loadCourse_success_setsTeachers() async {
        let mock = MockCoursesNetwork()

        mock.getTeachersResult = .success(
            TeachersResponse(
                teachers: [
                    Teacher(
                        id: "teacher-1",
                        firstName: "Иван",
                        lastName: "Иванов",
                        email: "teacher@test.com"
                    )
                ]
            )
        )

        mock.getCourseInfoResult = .success(
            CourseShortResponse(
                id: "course-1",
                name: "iOS Development",
                description: "Swift и UIKit",
                code: "IOS101",
                isActive: true
            )
        )

        let viewModel = CourseDetailsViewModel(
            courseId: "course-1",
            courseRepository: mock,
            onLeaveCourse: {}
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.teachers.count, 1)
    }

    func test_loadCourse_failure_setsError() async {
        let mock = MockCoursesNetwork()
        mock.getCourseInfoResult = .failure(TestError.mock)

        let viewModel = CourseDetailsViewModel(
            courseId: "1",
            courseRepository: mock,
            onLeaveCourse: {}
        )

        await viewModel.loadCourse()

        XCTAssertEqual(viewModel.errorMessage, "Не удалось загрузить курс")
    }

    func test_leaveCourse_success_callsCallback() async {
        let mock = MockCoursesNetwork()

        var called = false

        let viewModel = CourseDetailsViewModel(
            courseId: "1",
            courseRepository: mock,
            onLeaveCourse: {
                called = true
            }
        )

        await viewModel.leaveCourse()

        XCTAssertTrue(called)
    }

    func test_leaveCourse_failure_setsError() async {
        let mock = MockCoursesNetwork()
        mock.leaveCourseResult = .failure(TestError.mock)

        let viewModel = CourseDetailsViewModel(
            courseId: "1",
            courseRepository: mock,
            onLeaveCourse: {}
        )

        await viewModel.leaveCourse()

        XCTAssertEqual(viewModel.errorMessage, "Не удалось покинуть курс")
    }
}
