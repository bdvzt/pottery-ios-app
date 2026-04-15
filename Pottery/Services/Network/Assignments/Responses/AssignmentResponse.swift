struct AssignmentResponse: Decodable {
    let id: String
    let courseId: String
    let title: String?
    let text: String?
    let status: String?
    let startsAtUtc: String?
    let minTeamSize: Int?
    let maxTeamSize: Int?
    let teamFormationMode: String?
    let captainSelectionEndsAtUtc: String?
    let teamFormationStartsAtUtc: String?
    let teamFormationEndsAtUtc: String?
    let draftCurrentCaptainUserId: String?
    let draftStartedAtUtc: String?
    let draftCompletedAtUtc: String?
    let isTeamCompositionLocked: Bool?
    let teamCompositionLockedAtUtc: String?
    let isVisible: Bool?
    let isClosed: Bool?
    let requiresSubmission: Bool
    let deadline: String?
    let created: String
    let files: [AssignmentFile]?
}

enum AssignmentStatusKind {
    case available
    case hidden
    case closed
    case unknown
}

enum AssignmentTeamStateKind {
    case open
    case enrollmentClosed
    case compositionLocked
}

extension AssignmentResponse {
    var statusKind: AssignmentStatusKind {
        switch status?.lowercased() {
        case "available":
            return .available
        case "hidden":
            return .hidden
        case "closed":
            return .closed
        default:
            return .unknown
        }
    }

    var statusTitle: String {
        switch statusKind {
        case .available:
            return "Доступно"
        case .hidden:
            return "Скрыто"
        case .closed:
            return "Закрыто по статусу"
        case .unknown:
            return status ?? "Статус неизвестен"
        }
    }

    var shouldShowHiddenByVisibility: Bool {
        statusKind != .hidden && isVisible == false
    }

    var isTeamEnrollmentClosed: Bool {
        isClosed == true
    }

    var teamEnrollmentClosedTitle: String {
        "Набор в команды закрыт"
    }

    var teamStateKind: AssignmentTeamStateKind {
        if isTeamCompositionLocked == true {
            return .compositionLocked
        }
        if isTeamEnrollmentClosed {
            return .enrollmentClosed
        }
        return .open
    }

    var teamStateTitle: String? {
        switch teamStateKind {
        case .open:
            return nil
        case .enrollmentClosed:
            return teamEnrollmentClosedTitle
        case .compositionLocked:
            return "Команды зафиксированы"
        }
    }

    /// В API это не «можно ли загрузить решение», а нужен ли сценарий выбора финальной работы капитаном команды.
    var finalTeamSubmissionChipTitle: String {
        requiresSubmission ? "Выбор финала капитаном" : "Без финала команды"
    }

    var teamFormationTitle: String? {
        guard let teamFormationMode else { return nil }

        switch teamFormationMode.lowercased() {
        case "teacher_managed":
            return "Распределяет преподаватель"
        case "captain_draft":
            return "Драфт капитанов"
        case "random_distribution":
            return "Случайное распределение"
        default:
            return teamFormationMode
        }
    }

    var teamSizeTitle: String? {
        guard minTeamSize != nil || maxTeamSize != nil else { return nil }
        return "\(minTeamSize ?? 0)-\(maxTeamSize ?? 0)"
    }
}

struct AssignmentTeam: Decodable {
    let id: String
    let assignmentId: String
    let captain: AssignmentCaptain?
    let finalSubmissionId: String?
    let name: String?
    let createdAtUtc: String
    let members: [AssignmentTeamMember]?
}

struct AssignmentCaptain: Decodable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let createdAtUtc: String
}

struct AssignmentTeamMember: Decodable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let createdAtUtc: String
}
