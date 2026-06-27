import SwiftUI

struct GradesView: View {
    @StateObject var viewModel: GradesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if viewModel.grades.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("Оценок пока нет")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                ForEach(viewModel.grades, id: \.assignmentId) { grade in
                    gradeRow(grade)
                }
            }
            .padding()
        }
        .navigationTitle("Мои оценки")
        .task {
            await viewModel.loadGrades()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }

    private func gradeRow(_ grade: Grade) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(grade.assignmentTitle ?? "Без названия задания")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(grade.assignmentId)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(grade.grade.map(String.init) ?? "—")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(grade.grade == nil ? .secondary : Color.accentColor)

                if let calculated = GradeFormatting.calculatedGradeText(grade.calculatedGrade) {
                    Text(calculated)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(grade.grade == nil ? "Нет оценки" : "Оценка")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
