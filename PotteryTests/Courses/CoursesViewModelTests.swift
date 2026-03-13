import XCTest
@testable import Pottery

@MainActor
final class CoursesViewModelTests: XCTestCase {

    func test_loadCourses_success_setsCourses() async {
        let mock = MockCoursesNetwork()

        let course = Course(
            id: "course-1",
            name: "iOS Development",
            description: "Swift и UIKit",
            code: "IOS101",
            isActive: true,
            role: .student
        )

        mock.getCoursesResult = .success(
            CoursesResponse(courses: [course])
        )

        let viewModel = CoursesViewModel(
            courseRepository: mock,
            onOpenCourse: { _ in }
        )

        await viewModel.loadCourses()

        XCTAssertEqual(viewModel.courses.count, 1)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_loadCourses_failure_setsError() async {
        let mock = MockCoursesNetwork()
        mock.getCoursesResult = .failure(NSError())

        let viewModel = CoursesViewModel(
            courseRepository: mock,
            onOpenCourse: { _ in }
        )

        await viewModel.loadCourses()

        XCTAssertEqual(viewModel.errorMessage, "Не удалось загрузить курсы")
    }

    func test_loadCourses_setsLoading() async {
        let mock = MockCoursesNetwork()

        let viewModel = CoursesViewModel(
            courseRepository: mock,
            onOpenCourse: { _ in }
        )

        await viewModel.loadCourses()

        XCTAssertFalse(viewModel.isLoading)
    }

    func test_loadCourses_clearsPreviousError() async {
        let mock = MockCoursesNetwork()

        let viewModel = CoursesViewModel(
            courseRepository: mock,
            onOpenCourse: { _ in }
        )

        viewModel.errorMessage = "Old error"

        await viewModel.loadCourses()

        XCTAssertNil(viewModel.errorMessage)
    }

    func test_loadCourses_emptyResponse_setsEmptyCourses() async {
        let mock = MockCoursesNetwork()

        mock.getCoursesResult = .success(
            CoursesResponse(courses: [])
        )

        let viewModel = CoursesViewModel(
            courseRepository: mock,
            onOpenCourse: { _ in }
        )

        await viewModel.loadCourses()

        XCTAssertTrue(viewModel.courses.isEmpty)
    }
}
