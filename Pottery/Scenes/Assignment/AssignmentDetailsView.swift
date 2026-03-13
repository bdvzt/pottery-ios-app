import SwiftUI

struct AssignmentDetailsView: View {
    @StateObject var viewModel: AssignmentDetailsViewModel

    @State private var editingComment: Comment?
    @State private var editingText: String = ""
    @State private var showEditAlert = false

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

                        commentsBlock
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }

            }

            Spacer()

            commentInputBar
        }
        .alert("Редактировать комментарий", isPresented: $showEditAlert) {

            TextField("Комментарий", text: $editingText)

            Button("Сохранить") {
                if let comment = editingComment {
                    Task {
                        await viewModel.editComment(comment, text: editingText)
                    }
                }
            }

            Button("Отмена", role: .cancel) {}

        }
        .dismissKeyboardOnTap()
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

            if let grade = viewModel.grade?.grade {

                HStack {

                    Text("Оценка")

                    Spacer()

                    Text("\(grade)")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)

                }
                .font(.caption)
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

    private var commentsBlock: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Комментарии")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            if viewModel.comments.isEmpty {

                Text("Комментариев пока нет")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

            } else {

                VStack(spacing: 12) {

                    ForEach(viewModel.comments, id: \.id) { comment in
                        commentRow(comment)
                    }
                }
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                Text(comment.userName ?? "Пользователь")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                let date = comment.created
                    .split(separator: "T").first?
                    .replacingOccurrences(of: "-", with: ".") ?? ""

                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let text = comment.text {
                Text(text)
                    .font(.footnote)
            }

            if comment.userId == viewModel.profile?.id {

                HStack(spacing: 16) {

                    Button {
                        editingComment = comment
                        editingText = comment.text ?? ""
                        showEditAlert = true
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    .font(.caption)

                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteComment(comment)
                        }
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                    .font(.caption)

                    Spacer()
                }
                .padding(.top, 4)
            }

        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var commentInputBar: some View {

        HStack(spacing: 12) {

            TextField("Написать комментарий...", text: $viewModel.commentText)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                Task { await viewModel.sendComment() }
            } label: {

                if viewModel.isSendingComment {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accentColor)
                }

            }
        }
        .padding()
    }
}
