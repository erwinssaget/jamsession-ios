nonisolated enum QueueReconciliationOperation: Equatable, Sendable {
    case insert(PlaybackQueueItem, at: Int)
    case move(SubmissionID, from: Int, to: Int)
    case remove(SubmissionID, at: Int)
}
