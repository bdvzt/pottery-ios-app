import SwiftUI

struct CoursesView: View {
    @StateObject var viewModel: CoursesViewModel
    @State private var isJoinSheetPresented = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Мои курсы")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button {
                    isJoinSheetPresented = true
                } label: {
                    Label("Зачислиться по коду", systemImage: "plus.circle.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

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
        .sheet(isPresented: $isJoinSheetPresented, onDismiss: {
            viewModel.clearJoinState()
        }) {
            JoinCourseSheet(
                viewModel: viewModel,
                isPresented: $isJoinSheetPresented
            )
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

private struct JoinCourseSheet: View {
    @ObservedObject var viewModel: CoursesViewModel
    @Binding var isPresented: Bool
    @State private var courseCode = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Введите код курса")
                    .font(.headline)

                TextField("Например: IOS-2026", text: $courseCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if let joinErrorMessage = viewModel.joinErrorMessage {
                    Text(joinErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Зачисление")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                    .disabled(viewModel.isJoiningCourse)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let joined = await viewModel.joinCourse(code: courseCode)
                            if joined {
                                isPresented = false
                            }
                        }
                    } label: {
                        if viewModel.isJoiningCourse {
                            ProgressView()
                                .tint(Color.accentColor)
                        } else {
                            Text("Зачислиться")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(
                        viewModel.isJoiningCourse ||
                        courseCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }
}
