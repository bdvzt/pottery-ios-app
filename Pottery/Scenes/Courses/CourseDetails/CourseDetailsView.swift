import SwiftUI

struct CourseDetailsView: View {
    @StateObject var viewModel: CourseDetailsViewModel
    @State private var showLeaveAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let course = viewModel.course {
                        courseCard(course)
                    }

                    if !viewModel.teachers.isEmpty {
                        teachersCard(viewModel.teachers)
                    }

                    gradesButtonCard

                    if !viewModel.assignments.isEmpty {
                        assignmentsCard(viewModel.assignments)
                    }

                    leaveButton
                        .padding(.top, 16)

                }
                .padding()
            }
            .task {
                await viewModel.loadCourse()
            }
            .alert("Покинуть курс?", isPresented: $showLeaveAlert) {
                Button("Покинуть", role: .destructive) {
                    Task { await viewModel.leaveCourse() }
                }
                Button("Отмена", role: .cancel) { }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                }
            }
        }
    }

    // MARK: - Курс
    private func courseCard(_ course: CourseShortResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.name ?? "Без названия")
                .font(.title2)
                .fontWeight(.semibold)

            if let description = course.description {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text(course.isActive ? "Активный курс" : "Неактивный курс")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15))
                .foregroundStyle(Color.accentColor)
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Преподаватели
    private func teachersCard(_ teachers: [Teacher]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Преподаватели")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            ForEach(teachers, id: \.id) { teacher in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(teacher.firstName ?? "") \(teacher.lastName ?? "")")
                        .font(.subheadline)
                    if let email = teacher.email {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Задания
    private func assignmentsCard(_ assignments: [AssignmentResponse]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Задания")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            ForEach(assignments, id: \.id) { assignment in
                Button {
                    viewModel.openAssignment(assignment)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(assignment.title ?? "Без названия")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        if let text = assignment.text {
                            Text(text)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        HStack(spacing: 6) {
                            assignmentStatusChip(assignment)

                            if assignment.shouldShowHiddenByVisibility {
                                infoChip("Скрыто", color: .orange)
                            }

                            if let teamStateTitle = assignment.teamStateTitle {
                                let color: Color = assignment.teamStateKind == .compositionLocked ? .purple : .red
                                infoChip(teamStateTitle, color: color)
                            }
                        }

                        if let startsAt = assignment.startsAtUtc {
                            infoRow(title: "Старт", value: formatDate(startsAt), icon: "play.circle")
                        }

                        if let deadline = assignment.deadline {
                            Text("До \(formatDate(deadline))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        if let teamSizeTitle = assignment.teamSizeTitle {
                            infoRow(
                                title: "Размер команды",
                                value: teamSizeTitle,
                                icon: "person.3"
                            )
                        }

                        if let mode = assignment.teamFormationTitle {
                            infoRow(
                                title: "Формирование",
                                value: mode,
                                icon: "person.2.wave.2"
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var gradesButtonCard: some View {
        Button {
            viewModel.openGrades()
        } label: {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.body)
                Text("Мои оценки")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Кнопка покинуть курс
    private var leaveButton: some View {
        Button {
            showLeaveAlert = true
        } label: {
            Text("Покинуть курс")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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

    private func assignmentStatusChip(_ assignment: AssignmentResponse) -> some View {
        switch assignment.statusKind {
        case .available:
            return AnyView(infoChip(assignment.statusTitle, color: .green))
        case .hidden:
            return AnyView(infoChip(assignment.statusTitle, color: .orange))
        case .closed:
            return AnyView(infoChip(assignment.statusTitle, color: .red))
        case .unknown:
            return AnyView(infoChip(assignment.statusTitle, color: .gray))
        }
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

    private func formatDate(_ raw: String) -> String {
        if let date = parseISODate(raw) {
            return Self.outputDateFormatter.string(from: date)
        }
        return raw
    }

    private func parseISODate(_ raw: String) -> Date? {
        if let date = Self.iso8601FormatterWithFractionalSeconds.date(from: raw) {
            return date
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
