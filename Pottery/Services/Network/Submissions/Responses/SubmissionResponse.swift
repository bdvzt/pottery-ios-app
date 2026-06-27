import Foundation

struct SubmissionResponse: Decodable {

    let id: String
    let assignmentId: String
    let studentId: String
    let created: String
    let grade: Int?
    let calculatedGrade: Decimal?
    let teacherComment: String?
    let status: String
    let files: [SubmissionFile]

}
