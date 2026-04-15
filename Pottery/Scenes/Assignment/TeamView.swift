import SwiftUI

struct TeamView: View {
    @StateObject var viewModel: TeamViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                ForEach(Array(viewModel.teams.enumerated()), id: \.offset) { _, team in
                    teamCard(team)
                }

                if viewModel.canShowFinalSubmissionPicker {
                    finalSubmissionSection
                }

                if viewModel.teams.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("Команды пока не сформированы")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Состав команды")
        .task {
            await viewModel.load()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }

    private func teamCard(_ team: AssignmentTeam) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(team.name ?? "Команда")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(team.members?.count ?? 0) участ.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let members = team.members, !members.isEmpty {
                ForEach(Array(members.enumerated()), id: \.offset) { _, member in
                    HStack(spacing: 8) {
                        Text(memberName(member))
                            .font(.footnote)
                        if member.userId == team.captain?.userId {
                            Text("Капитан")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            } else {
                Text("Состав пока пуст")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var finalSubmissionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Финальное решение команды")
                .font(.headline)

            if !viewModel.canSelectFinalSubmissionNow {
                Text("Выбор финального решения сейчас недоступен.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let error = viewModel.finalSelectionErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if let team = viewModel.captainMyTeam {
                VStack(alignment: .leading, spacing: 10) {
                    Text(team.name ?? "Моя команда")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(Array(team.members.enumerated()), id: \.offset) { _, member in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(memberDisplayName(member))
                                .font(.footnote)
                                .fontWeight(.semibold)

                            let submissions: [CaptainMemberSubmission] = member.submissions ?? []
                            if submissions.isEmpty {
                                Text("Нет решений")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(Array(submissions.enumerated()), id: \.offset) { _, submission in
                                    HStack(spacing: 8) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Решение #\(submission.id.prefix(6))")
                                                .font(.caption)
                                            if let created = submission.created {
                                                Text(created)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                            if let grade = submission.grade {
                                                Text("Оценка: \(grade)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            } else {
                                                Text("Оценка еще не выставлена")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                            if let teacherComment = normalizedTeacherComment(submission.teacherComment) {
                                                Text("Комментарий: \(teacherComment)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }

                                        Spacer()

                                        if team.finalSubmissionId == submission.id {
                                            Text("Финальное")
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.green.opacity(0.15))
                                                .foregroundStyle(.green)
                                                .clipShape(Capsule())
                                        } else {
                                            Button {
                                                Task { await viewModel.selectFinalSubmission(submission.id) }
                                            } label: {
                                                if viewModel.isSelectingFinalSubmission {
                                                    ProgressView()
                                                } else {
                                                    Text("Выбрать финальным")
                                                }
                                            }
                                            .buttonStyle(.bordered)
                                            .disabled(viewModel.isSelectingFinalSubmission || !viewModel.canSelectFinalSubmissionNow)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func memberName(_ member: AssignmentTeamMember) -> String {
        let fullName = [member.lastName, member.firstName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return fullName.isEmpty ? (member.email ?? "Участник") : fullName
    }

    private func memberDisplayName(_ member: CaptainTeamMember) -> String {
        let fullName = [member.lastName, member.firstName, member.middleName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return fullName.isEmpty ? (member.email ?? "Участник") : fullName
    }

    private func normalizedTeacherComment(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
