import Foundation

enum CriterionType: String, Decodable {
    case passFail = "pass_fail"
    case score
    case option
    case multiplier

    var title: String {
        switch self {
        case .passFail: return "Да / нет"
        case .score: return "Баллы"
        case .option: return "Вариант"
        case .multiplier: return "Множитель"
        }
    }
}

enum CriterionCategory: String, Decodable {
    case main
    case bonus
    case penalty
    case multiplier

    var title: String {
        switch self {
        case .main: return "Основной"
        case .bonus: return "Бонус"
        case .penalty: return "Штраф"
        case .multiplier: return "Множитель"
        }
    }
}

struct CriterionGroupDto: Decodable, Identifiable, Equatable {
    let id: String
    let assignmentId: String?
    let name: String
    let description: String?
    let sortOrder: Int?

    var resolvedSortOrder: Int { sortOrder ?? 0 }
}

struct CriterionDto: Decodable, Identifiable, Equatable {
    let id: String
    let criterionGroupId: String?
    let name: String
    let description: String?
    let type: CriterionType
    let category: CriterionCategory
    let maxScore: Decimal?
    let sortOrder: Int?
    let settings: JSONValue?

    var resolvedSortOrder: Int { sortOrder ?? 0 }
}

// MARK: - Settings views

struct ScoreMappingView: Identifiable {
    let id = UUID()
    let value: String
    let score: Decimal?
}

struct ScoreRangeView: Identifiable {
    let id = UUID()
    let from: Int?
    let to: Int?
    let score: Decimal?
}

enum CriterionSettingsView {
    case passFail(options: [String], mappings: [ScoreMappingView])
    case score(min: Int?, max: Int?, multiplier: Decimal?, ranges: [ScoreRangeView])
    case option(options: [String], mappings: [ScoreMappingView])
    case multiplier(coefficient: Decimal?)
    case empty
}

extension CriterionDto {
    var parsedSettings: CriterionSettingsView {
        guard let object = settings?.objectValue else { return .empty }

        switch type {
        case .passFail:
            return .passFail(
                options: parseOptions(object["options"]),
                mappings: parseMappings(object["scoreMappings"])
            )
        case .option:
            return .option(
                options: parseOptions(object["options"]),
                mappings: parseMappings(object["scoreMappings"])
            )
        case .score:
            let minValue = object["minValue"]?.intValue
            let maxValue = object["maxValue"]?.intValue
            let multiplier = object["multiplier"]?.doubleValue.map { Decimal($0) }
            let ranges: [ScoreRangeView] = (object["ranges"]?.arrayValue ?? []).compactMap { item in
                guard let dict = item.objectValue else { return nil }
                return ScoreRangeView(
                    from: dict["from"]?.intValue,
                    to: dict["to"]?.intValue,
                    score: dict["score"]?.doubleValue.map { Decimal($0) }
                )
            }
            return .score(min: minValue, max: maxValue, multiplier: multiplier, ranges: ranges)
        case .multiplier:
            let coefficient = object["coefficient"]?.doubleValue.map { Decimal($0) }
            return .multiplier(coefficient: coefficient)
        }
    }

    private func parseOptions(_ value: JSONValue?) -> [String] {
        guard let array = value?.arrayValue else { return [] }
        return array.compactMap { item -> String? in
            if let direct = item.stringValue { return direct }
            if let object = item.objectValue {
                return (object["value"] ?? object["label"])?.stringValue
            }
            return nil
        }
    }

    private func parseMappings(_ value: JSONValue?) -> [ScoreMappingView] {
        guard let array = value?.arrayValue else { return [] }
        return array.compactMap { item -> ScoreMappingView? in
            guard let object = item.objectValue,
                  let key = object["value"]?.stringValue ?? object["label"]?.stringValue
            else { return nil }
            return ScoreMappingView(
                value: key,
                score: object["score"]?.doubleValue.map { Decimal($0) }
            )
        }
    }
}
