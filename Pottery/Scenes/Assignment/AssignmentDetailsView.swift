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
    @State private var newTeamName: String = ""

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

                    teamsSection

                    submissionSection

                    commentsSection
                }

            }
            .padding()
        }
    }

    // MARK: - Assignment Card

    private func assignmentCard(_ assignment: AssignmentResponse) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Text(assignment.title ?? "Без названия")
                .font(.title3)
                .fontWeight(.semibold)

            if let text = assignment.text {
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                statusChip(assignment)

                if assignment.shouldShowHiddenByVisibility {
                    infoChip("Скрыто", color: .orange)
                }

                if let teamStateTitle = assignment.teamStateTitle {
                    let color: Color = assignment.teamStateKind == .compositionLocked ? .purple : .red
                    infoChip(teamStateTitle, color: color)
                }
            }

            if let deadline = assignment.deadline {
                infoRow(title: "Дедлайн", value: formatDate(deadline), icon: "calendar")
            }

            if let startsAt = assignment.startsAtUtc {
                infoRow(title: "Старт задания", value: formatDate(startsAt), icon: "play.circle")
            }

            if let captainEnds = assignment.captainSelectionEndsAtUtc {
                infoRow(title: "Капитаны до", value: formatDate(captainEnds), icon: "person.badge.key")
            }

            if let formationStarts = assignment.teamFormationStartsAtUtc {
                infoRow(title: "Старт команд", value: formatDate(formationStarts), icon: "person.3")
            }

            if let formationEnds = assignment.teamFormationEndsAtUtc {
                infoRow(title: "Формирование до", value: formatDate(formationEnds), icon: "calendar.badge.clock")
            }

            if let teamSizeTitle = assignment.teamSizeTitle {
                infoRow(
                    title: "Размер команды",
                    value: teamSizeTitle,
                    icon: "person.2"
                )
            }

            if let mode = assignment.teamFormationTitle {
                infoRow(
                    title: "Режим команд",
                    value: mode,
                    icon: "person.2.wave.2"
                )
            }

            HStack {
                infoChip(
                    assignment.finalTeamSubmissionChipTitle,
                    color: assignment.requiresSubmission ? .accentColor : .secondary
                )

                Spacer()

                infoChip("Создано \(formatDate(assignment.created))", color: .gray)
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

    // MARK: - Teams

    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Команда")
                .font(.headline)

            if let teamErrorMessage = viewModel.teamErrorMessage {
                Text(teamErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if let myTeam = viewModel.myTeam {
                myTeamSection(myTeam)
            } else if viewModel.assignmentTeams.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Команды пока не созданы")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    TextField("Название команды (опционально)", text: $newTeamName)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task { await viewModel.createTeam(name: newTeamName) }
                    } label: {
                        if viewModel.isUpdatingTeam {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Создать команду")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isUpdatingTeam)
                }
            } else {
                Text("Выберите команду для вступления")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(viewModel.assignmentTeams, id: \.id) { team in
                    availableTeamRow(team)
                }
            }
        }
    }

    private func myTeamSection(_ team: AssignmentTeam) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(team.name ?? "Моя команда")
                .font(.subheadline)
                .fontWeight(.semibold)

            if let members = team.members, !members.isEmpty {
                ForEach(members, id: \.userId) { member in
                    Text(memberFullName(member))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Состав команды пока пуст")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button(role: .destructive) {
                Task { await viewModel.leaveMyTeam() }
            } label: {
                if viewModel.isUpdatingTeam {
                    ProgressView()
                } else {
                    Label("Выйти из команды", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            .disabled(viewModel.isUpdatingTeam)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func availableTeamRow(_ team: AssignmentTeam) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(team.name ?? "Команда")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(team.members?.count ?? 0) участ.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                Task { await viewModel.joinTeam(team) }
            } label: {
                if viewModel.isUpdatingTeam {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Вступить")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isUpdatingTeam)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        if let parsedDate = parseISODate(date) {
            return Self.outputDateFormatter.string(from: parsedDate)
        }
        return date
    }

    private func parseISODate(_ raw: String) -> Date? {
        if let value = Self.iso8601FormatterWithFractionalSeconds.date(from: raw) {
            return value
        }
        return Self.iso8601Formatter.date(from: raw)
    }

    private func memberFullName(_ member: AssignmentTeamMember) -> String {
        let name = [member.lastName, member.firstName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return name.isEmpty ? (member.email ?? "Участник") : name
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

    private func statusChip(_ assignment: AssignmentResponse) -> some View {
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

