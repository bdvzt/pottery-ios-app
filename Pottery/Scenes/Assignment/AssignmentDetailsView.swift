import SwiftUI

struct AssignmentDetailsView: View {
    @StateObject var viewModel: AssignmentDetailsViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Задание")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)

            if viewModel.isLoading {

                ProgressView()
                    .tint(Color.accentColor)

            }

            else if let error = viewModel.errorMessage {

                VStack(spacing: 12) {

                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)

                    Button("Обновить") {
                        Task { await viewModel.loadAssignment() }
                    }

                }

            }

            else if let assignment = viewModel.assignment {

                ScrollView {

                    VStack(alignment: .leading, spacing: 16) {

                        assignmentInfo(assignment)

                        if let files = assignment.files, !files.isEmpty {
                            filesBlock(files)
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }

            }

            Spacer()

        }
        .padding(24)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadAssignment()
        }
    }

    private func assignmentInfo(_ assignment: AssignmentResponse) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(assignment.title ?? "Без названия")
                .font(.title3)
                .fontWeight(.semibold)

            if let text = assignment.text {
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let deadline = assignment.deadline {
                let date = deadline
                        .split(separator: "T").first?
                        .replacingOccurrences(of: "-", with: ".") ?? ""

                HStack {

                    Text("Дедлайн")

                    Spacer()

                    Text(date)
                        .foregroundStyle(.secondary)

                }
                .font(.caption)
            }

            if assignment.requiresSubmission {

                Text("Требуется сдача")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func filesBlock(_ files: [AssignmentFile]) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Файлы")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 12) {

                ForEach(files, id: \.id) { file in
                    fileRow(file)
                }

            }

        }
    }

    private func fileRow(_ file: AssignmentFile) -> some View {

        HStack {

            Image(systemName: "doc")
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {

                Text(file.fileName)
                    .font(.subheadline)

                Text("\(file.size) bytes")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }

            Spacer()

        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
