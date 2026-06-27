import Foundation

struct Grade: Decodable {
    let assignmentId: String
    let assignmentTitle: String?
    let grade: Int?
    let calculatedGrade: Decimal?
    let teacherComment: String?
    let submissionId: String?

    init(
        assignmentId: String,
        assignmentTitle: String?,
        grade: Int?,
        calculatedGrade: Decimal? = nil,
        teacherComment: String? = nil,
        submissionId: String? = nil
    ) {
        self.assignmentId = assignmentId
        self.assignmentTitle = assignmentTitle
        self.grade = grade
        self.calculatedGrade = calculatedGrade
        self.teacherComment = teacherComment
        self.submissionId = submissionId
    }

    private enum CodingKeys: String, CodingKey {
        case assignmentId
        case assignmentTitle
        case grade
        case teamGrade
        case calculatedGrade
        case teacherComment
        case submissionId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assignmentId = try container.decode(String.self, forKey: .assignmentId)
        assignmentTitle = try container.decodeIfPresent(String.self, forKey: .assignmentTitle)
        let decodedGrade = try container.decodeIfPresent(Int.self, forKey: .grade)
        let decodedTeamGrade = try container.decodeIfPresent(Int.self, forKey: .teamGrade)
        grade = decodedGrade ?? decodedTeamGrade
        calculatedGrade = try container.decodeIfPresent(Decimal.self, forKey: .calculatedGrade)
        teacherComment = try container.decodeIfPresent(String.self, forKey: .teacherComment)
        submissionId = try container.decodeIfPresent(String.self, forKey: .submissionId)
    }
}
