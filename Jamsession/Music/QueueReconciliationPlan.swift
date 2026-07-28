nonisolated struct QueueReconciliationPlan: Equatable, Sendable {
    let originalSnapshot: PlaybackQueueSnapshot
    let desiredItems: [PlaybackQueueItem]
    let operations: [QueueReconciliationOperation]
}
