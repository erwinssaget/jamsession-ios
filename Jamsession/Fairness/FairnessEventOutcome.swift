nonisolated enum FairnessEventOutcome: Sendable, Equatable {
    case accepted
    case rejected(FairnessRejection)
}
