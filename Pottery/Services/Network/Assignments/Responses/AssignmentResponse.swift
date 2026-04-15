import Foundation
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

enum AssignmentStageKind {
    case captainSelection
    case teamFormation
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
        if isCompositionLockedEffective {
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

    var teamFormationTitle: String? {
        guard let teamFormationMode else { return nil }

        switch teamFormationMode.lowercased() {
        case "teacher_managed":
            return "Распределяет преподаватель"
        case "captain_draft":
            return "Драфт капитанов"
        case "random_distribution":
            return "Случайное распределение"
        case "student_self_selection":
            return "Самовыбор в команды"
        default:
            return teamFormationMode
        }
    }

    var teamSizeTitle: String? {
        guard minTeamSize != nil || maxTeamSize != nil else { return nil }
        return "\(minTeamSize ?? 0)-\(maxTeamSize ?? 0)"
    }

    var normalizedTeamFormationMode: String? {
        teamFormationMode?.lowercased()
    }

    var isTeacherManagedTeamFormation: Bool {
        normalizedTeamFormationMode == "teacher_managed"
    }

    /// Для этого режима бэкенд ожидает `POST .../captains/self` до создания команды через `POST .../teams`.
    var requiresCaptainVolunteerBeforeCreatingTeam: Bool {
        normalizedTeamFormationMode == "student_self_selection"
    }

    var canStudentSelfManageTeamMembership: Bool {
        normalizedTeamFormationMode == "student_self_selection"
    }

    /// `POST/DELETE .../captains/self` разрешены только если режим не teacher_managed (проверка на сервере).
    var allowsStudentCaptainSelfService: Bool {
        guard let normalizedTeamFormationMode else { return false }
        return normalizedTeamFormationMode != "teacher_managed"
    }

    /// Этап капитанов активен до `captainSelectionEndsAtUtc`.
    var isCaptainSelectionWindowOpen: Bool {
        isCaptainSelectionActive
    }

    var isCaptainSelectionActive: Bool {
        let now = Date()
        if let endStr = captainSelectionEndsAtUtc,
           let end = Self.parseApiUtc(endStr),
           now > end {
            return false
        }
        return captainSelectionEndsAtUtc != nil
    }

    var isTeamFormationActive: Bool {
        let now = Date()
        guard let formationEndRaw = teamFormationEndsAtUtc,
              let formationEnd = Self.parseApiUtc(formationEndRaw)
        else { return false }

        if let captainEndRaw = captainSelectionEndsAtUtc,
           let captainEnd = Self.parseApiUtc(captainEndRaw) {
            return now > captainEnd && now <= formationEnd
        }

        return now <= formationEnd
    }

    var isCompositionLockedByTimeline: Bool {
        guard let formationEndRaw = teamFormationEndsAtUtc,
              let formationEnd = Self.parseApiUtc(formationEndRaw)
        else { return false }
        return Date() > formationEnd
    }

    var isCompositionLockedEffective: Bool {
        isTeamCompositionLocked == true || isCompositionLockedByTimeline
    }

    var stageKind: AssignmentStageKind {
        if isCompositionLockedEffective {
            return .compositionLocked
        }
        if isTeamFormationActive {
            return .teamFormation
        }
        return .captainSelection
    }

    var stageTitle: String {
        switch stageKind {
        case .captainSelection:
            return "Выбор капитанов"
        case .teamFormation:
            return "Формирование команд"
        case .compositionLocked:
            return "Состав зафиксирован"
        }
    }

    var isAvailableForStudentNow: Bool {
        guard let formationEndRaw = teamFormationEndsAtUtc,
              let formationEnd = Self.parseApiUtc(formationEndRaw)
        else { return true }
        return Date() >= formationEnd
    }

    var isSubmissionWindowOpen: Bool {
        let now = Date()
        if let startRaw = startsAtUtc,
           let start = Self.parseApiUtc(startRaw),
           now < start {
            return false
        }
        if let deadlineRaw = deadline,
           let dl = Self.parseApiUtc(deadlineRaw),
           now > dl {
            return false
        }
        return true
    }

    private static func parseApiUtc(_ string: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = withFraction.date(from: string) { return d }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: string)
    }
}

struct CaptainAssignmentContextResponse: Decodable {
    let assignmentId: String
    let isCaptain: Bool
    let teamId: String?
    let finalSubmissionId: String?
    let canSelectFinalSubmission: Bool
}

struct AssignmentCaptainListItem: Decodable {
    let studentId: String?
    let userId: String?

    func matchesUser(_ profileId: String) -> Bool {
        if let userId, userId == profileId { return true }
        if let studentId, studentId == profileId { return true }
        return false
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

struct AssignmentDraftStateResponse: Decodable {
    let assignmentId: String?
    let isStarted: Bool
    let isCompleted: Bool
    let currentCaptainUserId: String?
    let teams: [AssignmentTeam]
    let availableStudents: [AssignmentDraftStudent]
}

struct AssignmentDraftStudent: Decodable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let isBlocked: Bool?

    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case firstName
        case lastName
        case email
        case isBlocked
    }
}

struct CaptainMyTeamResponse: Decodable {
    let id: String
    let assignmentId: String?
    let captain: AssignmentCaptain?
    let finalSubmissionId: String?
    let name: String?
    let members: [CaptainTeamMember]
}

struct CaptainTeamMember: Decodable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let email: String?
    let submissions: [CaptainMemberSubmission]?
}

struct CaptainMemberSubmission: Decodable {
    let id: String
    let assignmentId: String?
    let studentId: String?
    let created: String?
    let grade: Int?
    let teacherComment: String?
    let status: String?
    let files: [SubmissionFile]?
}
