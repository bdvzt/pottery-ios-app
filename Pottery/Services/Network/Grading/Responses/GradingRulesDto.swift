import Foundation

enum GradingMode: String, Decodable {
    case sumPoints = "sum_points"
    case baseWithMultipliers = "base_with_multipliers"

    var title: String {
        switch self {
        case .sumPoints: return "Сумма баллов"
        case .baseWithMultipliers: return "База × множители"
        }
    }
}

enum MainThresholdBehavior: String, Decodable {
    case setToZero = "set_to_zero"
    case markAsFailed = "mark_as_failed"

    var title: String {
        switch self {
        case .setToZero: return "обнуляет оценку"
        case .markAsFailed: return "отмечает решение как не сдано"
        }
    }
}

struct AssignmentGradingRulesDto: Decodable, Equatable {
    let mode: GradingMode
    let baseGrade: Decimal?
    let mainCriteriaThreshold: MainCriteriaThresholdDto?
    let penalties: GradingPenaltiesRulesDto?
}

struct MainCriteriaThresholdDto: Decodable, Equatable {
    let enabled: Bool
    let threshold: Decimal?
    let behavior: MainThresholdBehavior?
}

struct GradingPenaltiesRulesDto: Decodable, Equatable {
    let deadline: PenaltyRuleDto?
    let progress: PenaltyRuleDto?
    let requiredCriteria: PenaltyRuleDto?
}

struct PenaltyRuleDto: Decodable, Equatable {
    let enabled: Bool
    let percentage: Decimal?
}
