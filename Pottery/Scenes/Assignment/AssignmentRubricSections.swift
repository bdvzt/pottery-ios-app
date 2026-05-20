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

    // MARK: - Критерии

    var criteriaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Критерии")
                .font(.headline)

            if viewModel.criterionSections.isEmpty {
                Text(viewModel.criterionSectionsPlaceholder ?? "Критерии пока не настроены преподавателем.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.criterionSections) { section in
                    criterionGroupCard(section)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func criterionGroupCard(_ section: CriterionGroupSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.group.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            if let description = section.group.description,
               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if section.criteria.isEmpty {
                Text("Нет критериев")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(section.criteria) { criterion in
                    criterionRow(criterion)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func criterionRow(_ criterion: CriterionDto) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(criterion.name)
                    .font(.footnote)
                    .fontWeight(.semibold)
                Spacer()
                categoryBadge(criterion.category)
            }

            HStack(spacing: 8) {
                Text(criterion.type.title)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())

                if let max = criterion.maxScore,
                   let text = GradeFormatting.calculatedGradeText(max) {
                    Text("макс: \(text)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let description = criterion.description,
               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            settingsView(for: criterion.parsedSettings)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func settingsView(for settings: CriterionSettingsView) -> some View {
        switch settings {
        case .passFail(let options, let mappings),
             .option(let options, let mappings):
            optionsList(options: options, mappings: mappings)

        case .score(let min, let max, let multiplier, let ranges):
            scoreSettingsView(min: min, max: max, multiplier: multiplier, ranges: ranges)

        case .multiplier(let coefficient):
            if let text = GradeFormatting.calculatedGradeText(coefficient) {
                Text("Коэффициент: × \(text)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

        case .empty:
            EmptyView()
        }
    }

    @ViewBuilder
    private func optionsList(options: [String], mappings: [ScoreMappingView]) -> some View {
        let labels = mergedOptionLabels(options: options, mappings: mappings)
        if labels.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(labels, id: \.self) { line in
                    Text("• \(line)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func mergedOptionLabels(options: [String], mappings: [ScoreMappingView]) -> [String] {
        if !mappings.isEmpty {
            return mappings.map { mapping in
                if let scoreText = GradeFormatting.calculatedGradeText(mapping.score) {
                    return "\(mapping.value) — \(scoreText) б."
                }
                return mapping.value
            }
        }
        return options
    }

    @ViewBuilder
    private func scoreSettingsView(min: Int?, max: Int?, multiplier: Decimal?, ranges: [ScoreRangeView]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let line = rangeLine(min: min, max: max) {
                Text(line)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if let multiplier, let text = GradeFormatting.calculatedGradeText(multiplier) {
                Text("Множитель критерия: × \(text)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            ForEach(ranges) { range in
                Text("• \(rangeDescription(range))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func rangeLine(min: Int?, max: Int?) -> String? {
        switch (min, max) {
        case let (low?, high?): return "Диапазон: \(low)–\(high)"
        case let (low?, nil): return "От \(low)"
        case let (nil, high?): return "До \(high)"
        default: return nil
        }
    }

    private func rangeDescription(_ range: ScoreRangeView) -> String {
        let from = range.from.map(String.init) ?? "—"
        let to = range.to.map(String.init) ?? "—"
        let score = GradeFormatting.calculatedGradeText(range.score) ?? "—"
        return "\(from)–\(to): \(score) б."
    }

    private func categoryBadge(_ category: CriterionCategory) -> some View {
        let color: Color
        switch category {
        case .main: color = .blue
        case .bonus: color = .green
        case .penalty: color = .red
        case .multiplier: color = .purple
        }
        return Text(category.title)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
