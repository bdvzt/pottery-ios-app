import Foundation

enum GradeFormatting {
    static func roundedGradeText(_ grade: Int?) -> String? {
        grade.map(String.init)
    }

    static func calculatedGradeText(_ value: Decimal?) -> String? {
        guard let value else { return nil }
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: number)
    }

    static func pointsText(_ value: Decimal?) -> String {
        calculatedGradeText(value) ?? "—"
    }
}
