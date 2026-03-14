import SwiftUI
import PhotosUI

struct AssignmentDetailsView: View {

    @StateObject var viewModel: AssignmentDetailsViewModel

    @State private var editingComment: Comment?
    @State private var editingText = ""
    @State private var showEditAlert = false

    @State private var cameraImage: UIImage?
    @State private var galleryItem: PhotosPickerItem?

    @State private var selectedFile: AssignmentFile?

    var body: some View {
        VStack(spacing: 0) {

            content

            Divider()

            commentInputBar
        }
        .dismissKeyboardOnTap()
        .sheet(item: $selectedFile) { file in
            FileViewer(file: file)
        }
        .sheet(isPresented: $viewModel.showCamera) {
            CameraPicker(image: $cameraImage)
        }
        .photosPicker(
            isPresented: $viewModel.showGallery,
            selection: $galleryItem,
            matching: .images
        )
        .onChange(of: galleryItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.addImage(image)
                }
            }
        }
        .onChange(of: cameraImage) { image in
            if let image {
                viewModel.addImage(image)
            }
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
        .task {
            await viewModel.loadAssignment()
        }
    }

    // MARK: - Content

    private var content: some View {

        ScrollView {

            LazyVStack(spacing: 16) {

                if viewModel.isLoading {

                    ProgressView()
                        .padding(.top, 40)

                }

                else if let error = viewModel.errorMessage {

                    errorView(error)

                }

                else if let assignment = viewModel.assignment {

                    assignmentCard(assignment)

                    if let files = assignment.files, !files.isEmpty {
                        filesSection(files)
                    }

                    submissionSection

                    commentsSection
                }

            }
            .padding()
        }
    }

    // MARK: - Assignment Card

    private func assignmentCard(_ assignment: AssignmentResponse) -> some View {

        VStack(alignment: .leading, spacing: 10) {

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

                    Label(date, systemImage: "calendar")

                    Spacer()

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
                .font(.caption)
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
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Files

    private func filesSection(_ files: [AssignmentFile]) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Файлы")
                .font(.headline)

            ForEach(files, id: \.id) { file in
                fileRow(file)
            }
        }
    }

    private func fileRow(_ file: AssignmentFile) -> some View {

        Button {

            selectedFile = file

        } label: {

            HStack {

                Image(systemName: icon(for: file.mimeType))

                Text(file.fileName)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Submission

    private var submissionSection: some View {

        VStack(alignment: .center, spacing: 12) {

            Text("Ваше решение")
                .font(.headline)

            if let submission = viewModel.mySubmission {

                ForEach(submission.files, id: \.id) { file in
                    submissionFileRow(file)
                }

                Button(role: .destructive) {
                    Task { await viewModel.deleteSubmission() }
                } label: {
                    Label("Удалить решение", systemImage: "trash")
                }

            } else {

                if !viewModel.selectedImages.isEmpty {

                    ScrollView(.horizontal) {

                        HStack {

                            ForEach(viewModel.selectedImages, id: \.self) { image in

                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                HStack {

                    Button {
                        viewModel.showCamera = true
                    } label: {
                        Label("Камера", systemImage: "camera")
                    }

                    Button {
                        viewModel.showGallery = true
                    } label: {
                        Label("Галерея", systemImage: "photo")
                    }
                }

                Button {

                    Task { await viewModel.submitSolution() }

                } label: {

                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Text("Отправить решение")
                            .frame(maxWidth: .infinity)
                    }

                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 60)
            }
        }
    }

    // MARK: - Comments

    private var commentsSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Комментарии")
                .font(.headline)

            if viewModel.comments.isEmpty {

                Text("Комментариев пока нет")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

            } else {

                ForEach(viewModel.comments, id: \.id) { comment in
                    commentRow(comment)
                }
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack {

                Text(comment.userName ?? "Пользователь")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(formatDate(comment.created))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let text = comment.text {
                Text(text)
                    .font(.footnote)
            }

        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Input

    private var commentInputBar: some View {

        HStack(spacing: 10) {

            TextField("Комментарий...", text: $viewModel.commentText)
                .textFieldStyle(.roundedBorder)

            Button {

                Task { await viewModel.sendComment() }

            } label: {

                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 26))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: Helpers

    private func icon(for mime: String) -> String {

        if mime.contains("image") { return "photo" }
        if mime.contains("video") { return "video" }

        return "doc"
    }

    private func formatDate(_ date: String) -> String {

        date
            .split(separator: "T")
            .first?
            .replacingOccurrences(of: "-", with: ".") ?? ""
    }

    private func errorView(_ text: String) -> some View {

        VStack(spacing: 10) {

            Text(text)
                .foregroundStyle(.red)

            Button("Обновить") {
                Task { await viewModel.loadAssignment() }
            }
        }
    }

    private func submissionFileRow(_ file: SubmissionFile) -> some View {

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

            HStack {

                if file.mimeType.contains("image") {
                    Image(systemName: "photo")
                } else if file.mimeType.contains("video") {
                    Image(systemName: "video")
                } else {
                    Image(systemName: "doc")
                }

                Text(file.fileName)
                    .font(.subheadline)

                Spacer()

            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

