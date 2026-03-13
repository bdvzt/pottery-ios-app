import SwiftUI

struct CourseDetailsView: View {
    @StateObject var viewModel: CourseDetailsViewModel
    @State private var showLeaveAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("Курс")
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
                        Task { await viewModel.loadCourse() }
                    }
                }
            }

            else if let course = viewModel.course {

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        courseInfo(course)

                        teachersBlock
                            .padding(.horizontal, 16)

                        assignmentsBlock

                        Button {
                            showLeaveAlert = true
                        } label: {
                            Text("Покинуть курс")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
        .padding(24)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadCourse()
        }
        .alert("Покинуть курс?", isPresented: $showLeaveAlert) {
            Button("Покинуть", role: .destructive) {
                Task { await viewModel.leaveCourse() }
            }

            Button("Отмена", role: .cancel) { }
        }
    }

    private func courseInfo(_ course: CourseShortResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(course.name ?? "Без названия")
                .font(.title3)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var teachersBlock: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Преподаватели")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            if viewModel.teachers.isEmpty {
                Text("Нет преподавателей")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {

                ForEach(viewModel.teachers, id: \.id) { teacher in
                    teacherRow(teacher)
                }

            }
        }
    }

    private func teacherRow(_ teacher: Teacher) -> some View {
        VStack(alignment: .leading, spacing: 4) {

            Text("\(teacher.firstName ?? "") \(teacher.lastName ?? "")")
                .font(.subheadline)

            if let email = teacher.email {
                Text(email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var assignmentsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Задания")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            if viewModel.assignments.isEmpty {
                Text("Нет заданий")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {

                VStack(spacing: 12) {
                    ForEach(viewModel.assignments, id: \.id) { assignment in
                        assignmentRow(assignment)
                    }
                }

            }
        }
    }

    private func assignmentRow(_ assignment: AssignmentResponse) -> some View {

        Button {
            viewModel.openAssignment(assignment)
        } label: {

            VStack(alignment: .leading, spacing: 8) {

                Text(assignment.title ?? "Без названия")
                    .font(.headline)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
