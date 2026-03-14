import SwiftUI

struct CoursesView: View {
    @StateObject var viewModel: CoursesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Мои курсы")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                        .padding(.top, 40)
                }

                else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)

                        Button("Обновить") {
                            Task { await viewModel.loadCourses() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 20)
                }

                else if viewModel.courses.isEmpty {
                    Text("У вас пока нет курсов")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                }

                else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.courses, id: \.id) { course in
                            courseCard(course)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .task {
                await viewModel.loadCourses()
            }
        }
    }

    // MARK: - Карточка курса
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
                    Text(course.isActive ? "Активен" : "Не активен")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(course.isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                        .foregroundStyle(course.isActive ? Color.green : Color.gray)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}
