import Foundation

struct SubmissionAssessmentDto: Decodable, Equatable {
    let submissionId: String?
    let mainPoints: Decimal?
    let bonusPoints: Decimal?
    let penaltyPoints: Decimal?
    let multiplier: Decimal?
    let finalGrade: Decimal?
    let comment: String?
    let checkedAtUtc: String?
    let criterionValues: [SavedCriterionValueDto]?
}

struct SavedCriterionValueDto: Decodable, Equatable, Identifiable {
    let criterionId: String
    let value: JSONValue?

    var id: String { criterionId }
}
