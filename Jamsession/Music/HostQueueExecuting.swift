@MainActor
protocol HostQueueExecuting: AnyObject {
    func snapshot() -> PlaybackQueueSnapshot
    func apply(_ plan: QueueReconciliationPlan) async throws
    func pause()
}
