import SwiftUI

extension AssignmentDetailsView {

    // MARK: - Как оценивается

    var gradingRulesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Как оценивается")
                .font(.headline)

            if let placeholder = viewModel.gradingRulesPlaceholder, viewModel.gradingRules == nil {
                Text(placeholder)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if let rules = viewModel.gradingRules {
                gradingRulesContent(rules)
            } else {
                Text("Загрузка правил…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func gradingRulesContent(_ rules: AssignmentGradingRulesDto) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            rubricRow(title: "Формула", value: gradingFormulaText(rules))

            if rules.mode == .baseWithMultipliers,
               let baseText = GradeFormatting.calculatedGradeText(rules.baseGrade) {
                rubricRow(title: "Базовая оценка", value: baseText)
            }

            if let threshold = rules.mainCriteriaThreshold, threshold.enabled,
               let thresholdValue = threshold.threshold {
                rubricRow(
                    title: "Порог по основным критериям",
                    value: thresholdText(thresholdValue, behavior: threshold.behavior)
                )
            }

            penaltiesView(rules.penalties)
        }
    }

    private func gradingFormulaText(_ rules: AssignmentGradingRulesDto) -> String {
        switch rules.mode {
        case .sumPoints:
            return "сумма баллов критериев, затем штрафы и множители"
        case .baseWithMultipliers:
            return "базовая оценка × множители, затем штрафы"
        }
    }

    private func thresholdText(_ value: Decimal, behavior: MainThresholdBehavior?) -> String {
        let valueText = GradeFormatting.calculatedGradeText(value) ?? "—"
        guard let behavior else {
            return "Если основных набрано меньше \(valueText)%, итог корректируется."
        }
        return "Если основных меньше \(valueText)%, \(behavior.title)."
    }

    @ViewBuilder
    private func penaltiesView(_ penalties: GradingPenaltiesRulesDto?) -> some View {
        let active = activePenaltyLines(penalties)
        if active.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text("Штрафы")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(active, id: \.self) { line in
                    Text("• \(line)")
                        .font(.footnote)
                }
            }
        }
    }

    private func activePenaltyLines(_ penalties: GradingPenaltiesRulesDto?) -> [String] {
        guard let penalties else { return [] }
        var lines: [String] = []
        if let line = penaltyLine(penalties.deadline, title: "Просрочка дедлайна") { lines.append(line) }
        if let line = penaltyLine(penalties.progress, title: "Слабый прогресс") { lines.append(line) }
        if let line = penaltyLine(penalties.requiredCriteria, title: "Невыполнение обязательных критериев") { lines.append(line) }
        return lines
    }

    private func penaltyLine(_ rule: PenaltyRuleDto?, title: String) -> String? {
        guard let rule, rule.enabled else { return nil }
        if let percentage = rule.percentage,
           let text = GradeFormatting.calculatedGradeText(percentage) {
            return "\(title): −\(text)%"
        }
        return title
    }

    private func rubricRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.footnote)
                .multilineTextAlignment(.trailing)
        }
    }
}
