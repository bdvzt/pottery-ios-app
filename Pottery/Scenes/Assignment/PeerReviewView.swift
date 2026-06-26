import SwiftUI

struct PeerReviewView: View {
    @StateObject var viewModel: PeerReviewViewModel
    @State private var selectedFile: AssignmentFile?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading && viewModel.form == nil {
                    ProgressView()
                        .padding(.top, 40)
                } else if let error = viewModel.errorMessage, viewModel.form == nil {
                    errorCard(error)
                } else if let form = viewModel.form {
                    headerCard(form)

                    ForEach(viewModel.items) { item in
                        reviewedTeamCard(item, isReadOnly: form.isReadOnly)
                    }

                    if viewModel.items.isEmpty {
                        emptyCard("Назначения peer review пока не сформированы.")
                    }

                    saveSection(form)
                }
            }
            .padding()
        }
        .navigationTitle("Peer review")
        .dismissKeyboardOnTap()
        .sheet(item: $selectedFile) { file in
            FileViewer(file: file)
        }
        .task {
            await viewModel.load()
        }
    }

    private func headerCard(_ form: PeerReviewMyForm) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(form.reviewerTeamName ?? "Моя команда")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Команда проверяющих")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusChip(isCompleted: form.remainingCount == 0)
            }

            if let starts = form.peerReviewStartsAtUtc {
                infoRow(title: "Старт", value: formatDate(starts), icon: "play.circle")
            }
            if let ends = form.peerReviewEndsAtUtc {
                infoRow(title: "Дедлайн", value: formatDate(ends), icon: "calendar")
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Прогресс")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(form.completedCount) / \(form.totalCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                ProgressView(value: Double(form.completedCount), total: Double(max(form.totalCount, 1)))
                Text("Осталось: \(form.remainingCount)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if form.isReadOnly {
                Label("Редактирование закрыто", systemImage: "lock")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func reviewedTeamCard(_ item: PeerReviewFormItem, isReadOnly: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                viewModel.toggleExpanded(item)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.reviewedTeamName ?? "Команда")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("\(item.members?.count ?? 0) участ.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    statusChip(isCompleted: item.isCompleted)
                    Image(systemName: viewModel.expandedItemIds.contains(item.id) ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if viewModel.expandedItemIds.contains(item.id) {
                teamDetails(item, isReadOnly: isReadOnly)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func teamDetails(_ item: PeerReviewFormItem, isReadOnly: Bool) -> some View {
        if let members = item.members, !members.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Участники")
                ForEach(members, id: \.userId) { member in
                    Text(memberName(member))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }

        if let finalSubmission = item.finalSubmission {
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Финальное решение")
                submissionCard(finalSubmission, peerReviewAssignmentId: item.peerReviewAssignmentId, isReadOnly: isReadOnly)
            }
        }

        let groups = item.memberSubmissions ?? []
        if !groups.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Решения участников")
                ForEach(groups) { group in
                    memberSubmissionsCard(group, peerReviewAssignmentId: item.peerReviewAssignmentId, isReadOnly: isReadOnly)
                }
            }
        }
    }

    private func memberSubmissionsCard(
        _ group: PeerReviewTeamMemberSubmissions,
        peerReviewAssignmentId: String,
        isReadOnly: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(personName(firstName: group.firstName, lastName: group.lastName, middleName: group.middleName, fallback: "Участник"))
                .font(.subheadline)
                .fontWeight(.semibold)

            let submissions = group.submissions ?? []
            if submissions.isEmpty {
                Text("Решений нет")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(submissions) { submission in
                    submissionCard(submission, peerReviewAssignmentId: peerReviewAssignmentId, isReadOnly: isReadOnly)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func submissionCard(
        _ submission: PeerReviewSubmission,
        peerReviewAssignmentId: String,
        isReadOnly: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(personName(
                        firstName: submission.firstName,
                        lastName: submission.lastName,
                        middleName: submission.middleName,
                        fallback: "Решение"
                    ))
                    .font(.footnote)
                    .fontWeight(.semibold)

                    Text(formatDate(submission.created))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if submission.isRated {
                    infoChip("Оценено", color: .green)
                }
            }

            let files = submission.files ?? []
            if files.isEmpty {
                Text("Файлы не прикреплены")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(files, id: \.id) { file in
                    fileRow(file)
                }
            }

            ratingEditor(submission: submission, isReadOnly: isReadOnly)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func ratingEditor(submission: PeerReviewSubmission, isReadOnly: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Оценка")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(
                "0...100",
                text: Binding(
                    get: { viewModel.bindingForScore(submissionId: submission.id) },
                    set: { viewModel.updateScore(submissionId: submission.id, value: $0) }
                )
            )
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .disabled(isReadOnly)

            Text("Комментарий")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: Binding(
                get: { viewModel.bindingForComment(submissionId: submission.id) },
                set: { viewModel.updateComment(submissionId: submission.id, value: $0) }
            ))
            .frame(minHeight: 90)
            .padding(6)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(isReadOnly)

            Text("\(viewModel.bindingForComment(submissionId: submission.id).count) / 4000")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func saveSection(_ form: PeerReviewMyForm) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if let success = viewModel.successMessage {
                Text(success)
                    .font(.footnote)
                    .foregroundStyle(.green)
            }

            Button {
                Task { await viewModel.save() }
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Сохранить оценки")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(form.isReadOnly || viewModel.isSaving || !viewModel.hasChanges)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func fileRow(_ file: SubmissionFile) -> some View {
        Button {
            selectedFile = AssignmentFile(
                id: file.id,
                fileName: file.fileName,
                url: file.url,
                mimeType: file.mimeType,
                size: Int64(file.size),
                type: file.type
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon(for: file.mimeType))
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.fileName)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                    Text(file.mimeType)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func errorCard(_ text: String) -> some View {
        VStack(spacing: 10) {
            Text(text)
                .font(.footnote)
                .foregroundStyle(.red)
            Button("Обновить") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func emptyCard(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
    }

    private func statusChip(isCompleted: Bool) -> some View {
        infoChip(isCompleted ? "Готово" : "В работе", color: isCompleted ? .green : .orange)
    }

    private func infoChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 16, alignment: .center)
            Text("\(title): \(value)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func icon(for mime: String) -> String {
        if mime.contains("image") { return "photo" }
        if mime.contains("video") { return "video" }
        return "doc"
    }

    private func memberName(_ member: AssignmentTeamMember) -> String {
        personName(
            firstName: member.firstName,
            lastName: member.lastName,
            middleName: member.middleName,
            fallback: member.email ?? "Участник"
        )
    }

    private func personName(firstName: String?, lastName: String?, middleName: String?, fallback: String) -> String {
        let value = [lastName, firstName, middleName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return value.isEmpty ? fallback : value
    }

    private func formatDate(_ raw: String) -> String {
        if let parsedDate = parseISODate(raw) {
            return Self.outputDateFormatter.string(from: parsedDate)
        }
        return raw
    }

    private func parseISODate(_ raw: String) -> Date? {
        if let value = Self.iso8601FormatterWithFractionalSeconds.date(from: raw) {
            return value
        }
        return Self.iso8601Formatter.date(from: raw)
    }

    private static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm dd.MM.yyyy"
        return formatter
    }()

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let iso8601FormatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
