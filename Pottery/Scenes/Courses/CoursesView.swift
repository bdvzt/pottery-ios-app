import SwiftUI

struct CoursesView: View {
    @StateObject var viewModel: CoursesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Мои курсы")
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
                            Task { await viewModel.loadCourses() }
                        }
                    }
                }
                else if viewModel.courses.isEmpty {
                    Text("У вас пока нет курсов")
                        .foregroundStyle(.secondary)
                }
                else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.courses, id: \.id) { course in
                            courseCard(course)
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadCourses()
        }
    }

    private func courseCard(_ course: Course) -> some View {
        Button {
            viewModel.openCourse(
                CourseShortResponse(
                    id: course.id,
                    name: course.name,
                    description: course.description,
                    code: course.code,
                    isActive: course.isActive
                )
            )
        } label: {

            VStack(alignment: .leading, spacing: 8) {

                Text(course.name ?? "Без названия")
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let description = course.description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Spacer()

                    if course.isActive {
                        Text("Активен")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    } else {
                        Text("Не активен")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
