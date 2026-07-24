nonisolated enum QueueCommandOutcome: Sendable, Equatable {
    case accepted
    case rejected(FairnessRejection)
}
