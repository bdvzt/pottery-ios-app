import Foundation

struct PeerReviewPersonalStatus: Decodable {
    let assignmentId: String
    let totalCount: Int
    let completedCount: Int
    let remainingCount: Int
    let isCompleted: Bool
}

struct PeerReviewTeamStatus: Decodable {
    let assignmentId: String
    let teamId: String
    let teamName: String?
    let peerReviewStartsAtUtc: String?
    let peerReviewEndsAtUtc: String?
    let requiredReviewsCount: Int
    let membersCount: Int
    let completedMembersCount: Int
    let remainingMembersCount: Int
    let isCompleted: Bool
    let currentStudent: PeerReviewTeamMemberStatus?
    let members: [PeerReviewTeamMemberStatus]?
}

struct PeerReviewTeamMemberStatus: Decodable, Identifiable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let totalCount: Int
    let completedCount: Int
    let remainingCount: Int
    let isCompleted: Bool

    var id: String { userId }
}

struct PeerReviewMyForm: Decodable {
    let assignmentId: String
    let reviewerTeamId: String
    let reviewerTeamName: String?
    let peerReviewStartsAtUtc: String?
    let peerReviewEndsAtUtc: String?
    let isReadOnly: Bool
    let totalCount: Int
    let completedCount: Int
    let remainingCount: Int
    let items: [PeerReviewFormItem]?
}

struct PeerReviewFormItem: Decodable, Identifiable {
    let peerReviewAssignmentId: String
    let reviewedTeamId: String
    let reviewedTeamName: String?
    let members: [AssignmentTeamMember]?
    let memberSubmissions: [PeerReviewTeamMemberSubmissions]?
    let finalSubmission: PeerReviewSubmission?
    let isCompleted: Bool
    let score: Decimal?
    let comment: String?

    var id: String { peerReviewAssignmentId }
}

struct PeerReviewTeamMemberSubmissions: Decodable, Identifiable {
    let userId: String
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let submissions: [PeerReviewSubmission]?

    var id: String { userId }
}

struct PeerReviewSubmission: Decodable, Identifiable {
    let id: String
    let studentId: String
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let created: String
    let isRated: Bool
    let score: Decimal?
    let comment: String?
    let files: [SubmissionFile]?
}

struct UpdatePeerReviewRatingsRequest: Encodable {
    let ratings: [PeerReviewRatingRequest]
}

struct PeerReviewRatingRequest: Encodable {
    let peerReviewAssignmentId: String
    let submissionId: String
    let score: Decimal
    let comment: String?
}

struct PeerReviewRating: Decodable {
    let id: String
    let peerReviewAssignmentId: String
    let submissionId: String
    let reviewerUserId: String
    let reviewedUserId: String
    let score: Decimal
    let comment: String?
    let createdAtUtc: String
    let updatedAtUtc: String
}
