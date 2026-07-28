#if DEBUG
@MainActor
final class DebugHostQueueExecutor: HostQueueExecuting {
    private var items: [PlaybackQueueItem] = []

    func snapshot() -> PlaybackQueueSnapshot {
        PlaybackQueueSnapshot(items: items)
    }

    func apply(_ plan: QueueReconciliationPlan) async throws {
        guard snapshot() == plan.originalSnapshot else {
            throw HostPlaybackError.queueChanged
        }
        items = plan.desiredItems
    }

    func pause() {
    }
}
#endif
