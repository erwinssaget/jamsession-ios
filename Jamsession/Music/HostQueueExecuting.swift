@MainActor
protocol HostQueueExecuting: AnyObject {
    func snapshot() -> PlaybackQueueSnapshot
    func apply(_ plan: QueueReconciliationPlan) async throws
    func observePlayback(
        _ receive: @escaping @MainActor @Sendable (HostPlaybackObservation) -> Void
    ) async
    func play() async throws
    func pause()
    func skipToNextEntry() async throws
}
