import SwiftUI
import UniformTypeIdentifiers

struct AssignmentDetailsView: View {

    @StateObject var viewModel: AssignmentDetailsViewModel

    @State private var selectedFile: AssignmentFile?
    @State private var newTeamName: String = ""
    @State private var showCaptainWarning = false
    @State private var showCreateTeamAlert = false
    @State private var showTeamSheet = false
    @State private var showFileImporter = false

    var body: some View {
        VStack(spacing: 0) {

            content
        }
        .dismissKeyboardOnTap()
        .sheet(item: $selectedFile) { file in
            FileViewer(file: file)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task { await viewModel.addPickedFiles(urls: urls) }
            case .failure:
                viewModel.errorMessage = "Не удалось выбрать файлы"
            }
        }
        .alert("Стать капитаном?", isPresented: $showCaptainWarning) {
            Button("Отмена", role: .cancel) {}
            Button("ОК") {
                Task { await viewModel.selfAssignAsCaptain() }
            }
        } message: {
            Text("После выбора роли капитана вы не сможете выйти из своей команды.")
        }
        .alert("Название команды", isPresented: $showCreateTeamAlert) {
            TextField("Введите название", text: $newTeamName)
            Button("Отмена", role: .cancel) {}
            Button("Создать") {
                let teamName = newTeamName
                newTeamName = ""
                Task { await viewModel.createTeam(name: teamName) }
            }
        } message: {
            Text("Укажите название перед созданием команды.")
        }
        .sheet(isPresented: $showTeamSheet) {
            NavigationStack {
                TeamView(viewModel: viewModel.makeTeamViewModel())
            }
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

                    if viewModel.isCaptainDraftMode {
                        draftSection
                    }

                    submissionSection
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
                stageChip(assignment)

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

            if let captainsAndTeamStart = assignment.captainSelectionEndsAtUtc ?? assignment.teamFormationStartsAtUtc {
                infoRow(
                    title: "Капитаны до / старт команд",
                    value: formatDate(captainsAndTeamStart),
                    icon: "person.3"
                )
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
                Spacer()
                infoChip("Создано \(formatDate(assignment.created))", color: .gray)
            }

            HStack {
                Text("Оценка")
                Spacer()
                if let grade = viewModel.grade?.grade {
                    Text("\(grade)")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                } else {
                    Text("Нет оценки")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption)

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

        VStack(alignment: .leading, spacing: 12) {

            Text("Ваше решение")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let submission = viewModel.mySubmission {
                submissionFeedbackSection(submission)

                if submission.files.isEmpty {
                    Text("Файлы еще не прикреплены")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Выберите файлы для удаления")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ForEach(submission.files, id: \.id) { file in
                        selectableSubmissionFileRow(file)
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        showFileImporter = true
                    } label: {
                        Label("Добавить файлы", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        Task { await viewModel.deleteSelectedSubmissionFiles() }
                    } label: {
                        Label("Удалить выбранные", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.selectedSubmissionFileIds.isEmpty)
                }

                if !viewModel.pendingUploadFiles.isEmpty {
                    pendingUploadFilesView
                }

                Button {
                    Task { await viewModel.submitSolution() }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Text("Загрузить добавленные файлы")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.pendingUploadFiles.isEmpty || viewModel.isSubmitting)

                if !viewModel.selectedSubmissionFileIds.isEmpty {
                    Button("Снять выделение") {
                        viewModel.clearSubmissionFileSelection()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

            } else {
                Text("Решение еще не отправлено")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !viewModel.pendingUploadFiles.isEmpty {
                    pendingUploadFilesView
                }

                HStack {

                    Button {
                        showFileImporter = true
                    } label: {
                        Label("Файлы", systemImage: "doc")
                    }
                }

                Button {

                    Task { await viewModel.submitSolution() }

                } label: {

                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Text("Прикрепить файлы")
                            .frame(maxWidth: .infinity)
                    }

                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 60)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Teams

    private var teamsSection: some View {
        Group {
            if let assignment = viewModel.assignment {
                teamsSectionContent(assignment)
            }
        }
    }

    // MARK: - Captain Draft

    private var draftSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Драфт капитанов")
                .font(.headline)

            if let draftErrorMessage = viewModel.draftErrorMessage {
                Text(draftErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if viewModel.isDraftLoading && viewModel.draftState == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let draftState = viewModel.draftState {
                draftStatusView(draftState)

                if !draftState.teams.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Команды драфта")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(draftState.teams, id: \.id) { team in
                            availableTeamRow(team, canJoin: false)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if draftState.isStarted && !draftState.isCompleted {
                    draftStudentsPicker(draftState)
                }
            } else {
                Text("Ожидаем запуск преподавателем.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func draftStatusView(_ state: AssignmentDraftStateResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if !state.isStarted {
                Text("Ожидаем запуск преподавателем.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if state.isCompleted {
                Text("Драфт завершен")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if viewModel.isMyDraftTurn {
                Text("Сейчас ваш ход выбора")
                    .font(.footnote)
                    .foregroundStyle(.green)
            } else {
                Text("Сейчас ход другого капитана")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func draftStudentsPicker(_ state: AssignmentDraftStateResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Доступные студенты")
                .font(.subheadline)
                .fontWeight(.semibold)

            if state.availableStudents.isEmpty {
                Text("Свободных студентов не осталось.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(state.availableStudents, id: \.userId) { student in
                    HStack(spacing: 10) {
                        Image(systemName: "person")
                            .foregroundStyle(.secondary)

                        Text(draftStudentFullName(student))
                            .font(.footnote)
                            .lineLimit(1)

                        Spacer()

                        if viewModel.isMyDraftTurn {
                            Button {
                                Task { await viewModel.pickDraftStudent(student) }
                            } label: {
                                if viewModel.isUpdatingTeam {
                                    ProgressView()
                                } else {
                                    Text("Выбрать")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isUpdatingTeam)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func teamsSectionContent(_ assignment: AssignmentResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Команда")
                    .font(.headline)
                Spacer()
                Button("Состав команды") {
                    showTeamSheet = true
                }
                .font(.footnote)
            }

            if let teamErrorMessage = viewModel.teamErrorMessage {
                Text(teamErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if let myTeam = viewModel.myTeam {
                myTeamSection(myTeam)
            } else {
                Text("Вы еще не состоите в команде")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Текущие команды")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if viewModel.assignmentTeams.isEmpty {
                    Text("Пока нет созданных команд.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.assignmentTeams, id: \.id) { team in
                        availableTeamRow(
                            team,
                            canJoin: viewModel.myTeam == nil && assignment.canStudentSelfManageTeamMembership
                        )
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if viewModel.myTeam == nil {
                teamActionsSection(assignment)
            }
        }
    }

    @ViewBuilder
    private func teamActionsSection(_ assignment: AssignmentResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Действия")
                .font(.subheadline)
                .fontWeight(.semibold)

            if viewModel.isCaptainDraftMode {
                Text("В этом задании команды собираются через драфт капитанов.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if assignment.isTeacherManagedTeamFormation {
                Text("Команды в этом задании формирует преподаватель.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if assignment.requiresCaptainVolunteerBeforeCreatingTeam {
                if viewModel.isVolunteerCaptain {
                    if assignment.isCaptainSelectionActive {
                        Button(role: .destructive) {
                            Task { await viewModel.withdrawCaptainVolunteer() }
                        } label: {
                            if viewModel.isUpdatingTeam {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Отказаться от роли капитана")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isUpdatingTeam)
                    }

                    if viewModel.assignmentTeams.isEmpty {
                        Text("Команды пока не созданы")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        createTeamTriggerButton(title: "Создать команду")
                    } else {
                        Text("Вы уже капитан. Для этого режима новая команда недоступна.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if assignment.isCaptainSelectionActive {
                    Text(
                        viewModel.assignmentTeams.isEmpty
                            ? "Сначала запишитесь капитаном — после этого можно создать команду."
                            : "Чтобы создать свою команду, сначала запишитесь капитаном."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    captainSelfAssignButton()
                } else {
                    Text("Этап выбора капитанов завершен. Создать новую команду сейчас нельзя.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else if assignment.canStudentSelfManageTeamMembership {
                if viewModel.assignmentTeams.isEmpty {
                    Text("Создайте первую команду для задания.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    createTeamTriggerButton(title: "Создать команду")
                } else if viewModel.myTeam == nil {
                    createAdditionalTeamForm()
                } else {
                    Text("Вы уже состоите в команде.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("В этом режиме доступен только просмотр состава команд.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

            if viewModel.assignment?.canStudentSelfManageTeamMembership == true && !isCurrentUserCaptain(of: team) {
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
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func availableTeamRow(_ team: AssignmentTeam, canJoin: Bool) -> some View {
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

            if let members = team.members, !members.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Участники")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(members.prefix(4), id: \.userId) { member in
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(memberFullName(member))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    if members.count > 4 {
                        Text("+\(members.count - 4) еще")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 2)
            }

            if canJoin {
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
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func createAdditionalTeamForm() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Можно создать новую команду")
                .font(.footnote)
                .foregroundStyle(.secondary)
            createTeamTriggerButton(title: "Создать еще одну команду")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func createTeamTriggerButton(title: String) -> some View {
        Button {
            showCreateTeamAlert = true
        } label: {
            if viewModel.isUpdatingTeam {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isUpdatingTeam)
        .frame(maxWidth: .infinity)
    }

    private func captainSelfAssignButton() -> some View {
        Button {
            showCaptainWarning = true
        } label: {
            if viewModel.isUpdatingTeam {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Стать капитаном")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isUpdatingTeam)
    }

    private func stageChip(_ assignment: AssignmentResponse) -> some View {
        let color: Color
        switch assignment.stageKind {
        case .captainSelection:
            color = .blue
        case .teamFormation:
            color = .orange
        case .compositionLocked:
            color = .purple
        }
        return infoChip(assignment.stageTitle, color: color)
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

    private func isSameMoment(_ lhs: String, _ rhs: String) -> Bool {
        guard let leftDate = parseISODate(lhs), let rightDate = parseISODate(rhs) else {
            return false
        }
        return abs(leftDate.timeIntervalSince(rightDate)) < 1
    }

    private func memberFullName(_ member: AssignmentTeamMember) -> String {
        let name = [member.lastName, member.firstName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return name.isEmpty ? (member.email ?? "Участник") : name
    }

    private func draftStudentFullName(_ student: AssignmentDraftStudent) -> String {
        let name = [student.lastName, student.firstName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return name.isEmpty ? (student.email ?? "Студент") : name
    }

    private func isCurrentUserCaptain(of team: AssignmentTeam) -> Bool {
        guard let profileId = viewModel.profile?.id else { return false }
        return team.captain?.userId == profileId
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

    private func selectableSubmissionFileRow(_ file: SubmissionFile) -> some View {
        Button {
            viewModel.toggleSubmissionFileSelection(file.id)
        } label: {
            HStack(spacing: 10) {
                Image(
                    systemName: viewModel.selectedSubmissionFileIds.contains(file.id)
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .foregroundStyle(
                    viewModel.selectedSubmissionFileIds.contains(file.id)
                        ? Color.accentColor
                        : Color.secondary
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(file.fileName)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(file.mimeType)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

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
                    Image(systemName: "eye")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var pendingUploadFilesView: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(viewModel.pendingUploadFiles) { file in
                HStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.fileName)
                            .font(.footnote)
                            .lineLimit(1)
                        Text(file.mimeType)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        viewModel.removePendingUploadFile(file.id)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                .padding(8)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func submissionFeedbackSection(_ submission: SubmissionResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Оценка")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                if let grade = submission.grade {
                    Text("\(grade)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                } else {
                    Text("Оценка еще не выставлена")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let comment = normalizedTeacherComment(submission.teacherComment) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Комментарий преподавателя")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(comment)
                        .font(.footnote)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func normalizedTeacherComment(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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

