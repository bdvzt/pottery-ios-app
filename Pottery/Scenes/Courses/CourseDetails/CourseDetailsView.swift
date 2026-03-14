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
                    VStack(alignment: .leading, spacing: 6) {
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

                        HStack {
                            if assignment.requiresSubmission {
                                Text("Требуется сдача")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }

                            Spacer()

                            if let deadline = assignment.deadline {
                                let date = deadline
                                    .split(separator: "T").first?
                                    .replacingOccurrences(of: "-", with: ".") ?? ""
                                Text("До \(date)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
}
