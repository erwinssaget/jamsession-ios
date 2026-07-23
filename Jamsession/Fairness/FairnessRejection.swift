nonisolated enum FairnessRejection: Error, Sendable, Equatable {
    case duplicate
    case pendingLimitReached(limit: Int)
    case participantNotFound
    case participantNotActive
    case participantAlreadyExists
    case participantRemoved
    case unauthorizedAction
    case submissionNotFound
    case notNextUp
    case nothingPlaying
}
