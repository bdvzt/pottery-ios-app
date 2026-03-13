import XCTest
@testable import Pottery

@MainActor
final class AssignmentDetailsViewModelTests: XCTestCase {

    func test_loadAssignment_success_setsAssignment() async {

        let assignmentsMock = MockAssignmentsNetwork()
        let commentsMock = MockCommentsNetwork()
        let usersMock = MockUsersNetwork()

        let assignment = AssignmentResponse(
            id: "assignment-1",
            courseId: "course-1",
            title: "Homework",
            text: "Do task",
            requiresSubmission: true,
            deadline: nil,
            created: "2024-01-01",
            files: nil
        )

        assignmentsMock.getAssignmentResult = .success(assignment)

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            commentsRepository: commentsMock,
            usersRepository: usersMock
        )

        await viewModel.loadAssignment()

        XCTAssertEqual(viewModel.assignment?.id, "assignment-1")
    }

    func test_loadAssignment_success_setsComments() async {

        let assignmentsMock = MockAssignmentsNetwork()
        let commentsMock = MockCommentsNetwork()
        let usersMock = MockUsersNetwork()

        assignmentsMock.getAssignmentResult = .success(
            AssignmentResponse(
                id: "assignment-1",
                courseId: "course-1",
                title: "Homework",
                text: nil,
                requiresSubmission: false,
                deadline: nil,
                created: "2024-01-01",
                files: nil
            )
        )

        commentsMock.getCommentsResult = .success([
            Comment(
                id: "comment-1",
                assignmentId: "assignment-1",
                userId: "user-1",
                userName: "Иван Иванов",
                text: "Отличное задание!",
                created: "2024-01-01T10:00:00Z"
            )
        ])

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            commentsRepository: commentsMock,
            usersRepository: usersMock
        )

        await viewModel.loadAssignment()

        XCTAssertEqual(viewModel.comments.count, 1)
    }

    func test_sendComment_success_addsComment() async {

        let assignmentsMock = MockAssignmentsNetwork()
        let commentsMock = MockCommentsNetwork()
        let usersMock = MockUsersNetwork()

        let comment = Comment(
            id: "comment-1",
            assignmentId: "assignment-1",
            userId: "user-1",
            userName: "Иван Иванов",
            text: "Отличное задание!",
            created: "2024-01-01T10:00:00Z"
        )

        commentsMock.createCommentResult = .success(comment)

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            commentsRepository: commentsMock,
            usersRepository: usersMock
        )

        viewModel.commentText = "Hello"

        await viewModel.sendComment()

        XCTAssertEqual(viewModel.comments.count, 1)
        XCTAssertEqual(viewModel.commentText, "")
    }

    func test_deleteComment_removesComment() async {

        let assignmentsMock = MockAssignmentsNetwork()
        let commentsMock = MockCommentsNetwork()
        let usersMock = MockUsersNetwork()

        let comment = Comment(
            id: "comment-1",
            assignmentId: "assignment-1",
            userId: "user-1",
            userName: "Иван Иванов",
            text: "Отличное задание!",
            created: "2024-01-01T10:00:00Z"
        )

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            commentsRepository: commentsMock,
            usersRepository: usersMock
        )

        viewModel.comments = [comment]

        await viewModel.deleteComment(comment)

        XCTAssertTrue(viewModel.comments.isEmpty)
    }

    func test_sendComment_failure_setsError() async {

        let assignmentsMock = MockAssignmentsNetwork()
        let commentsMock = MockCommentsNetwork()
        let usersMock = MockUsersNetwork()

        commentsMock.createCommentResult = .failure(TestError.mock)

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            commentsRepository: commentsMock,
            usersRepository: usersMock
        )

        viewModel.commentText = "Hello"

        await viewModel.sendComment()

        XCTAssertEqual(viewModel.errorMessage, "Не удалось отправить комментарий")
    }

    func test_loadAssignment_success_setsGrade() async {

        let assignmentsMock = MockAssignmentsNetwork()
        let commentsMock = MockCommentsNetwork()
        let usersMock = MockUsersNetwork()

        let assignment = AssignmentResponse(
            id: "assignment-s1",
            courseId: "course-1",
            title: "Homework",
            text: nil,
            requiresSubmission: false,
            deadline: nil,
            created: "2024-01-01",
            files: nil
        )

        assignmentsMock.getAssignmentResult = .success(assignment)

        assignmentsMock.getGradesResult = .success([
            Grade(
                assignmentId: "assignment-1",
                assignmentTitle: "Homework",
                grade: 5
            )
        ])

        let viewModel = AssignmentDetailsViewModel(
            assignmentId: "assignment-1",
            assignmentsRepository: assignmentsMock,
            commentsRepository: commentsMock,
            usersRepository: usersMock
        )

        await viewModel.loadAssignment()

        XCTAssertEqual(viewModel.grade?.grade, 5)
    }
}
