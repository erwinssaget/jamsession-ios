#if DEBUG
import Foundation

@MainActor
final class DebugHostQueueExecutor: HostQueueExecuting {
    private var items: [PlaybackQueueItem] = []
    private var observation = HostPlaybackObservation(
        currentItem: .none,
        status: .stopped
    )
    private let controlError: HostPlaybackError?
    private var observationContinuations: [
        UUID: AsyncStream<HostPlaybackObservation>.Continuation
    ] = [:]

    init(controlError: HostPlaybackError? = nil) {
        self.controlError = controlError
    }

    func snapshot() -> PlaybackQueueSnapshot {
        PlaybackQueueSnapshot(items: items)
    }

    func apply(_ plan: QueueReconciliationPlan) async throws {
        guard snapshot() == plan.originalSnapshot else {
            throw HostPlaybackError.queueChanged
        }
        items = plan.desiredItems
        if !items.contains(where: { $0.id == observation.currentItem.managedID }) {
            updateObservation(
                HostPlaybackObservation(
                    currentItem: items.first.map { .managed($0.id) } ?? .none,
                    status: .stopped
                )
            )
        }
    }

    func observePlayback(
        _ receive: @escaping @MainActor @Sendable (HostPlaybackObservation) -> Void
    ) async {
        let observationID = UUID()
        let observations = AsyncStream<HostPlaybackObservation> { continuation in
            observationContinuations[observationID] = continuation
            continuation.yield(observation)
        }
        defer {
            observationContinuations[observationID] = nil
        }

        for await observation in observations {
            guard !Task.isCancelled else {
                return
            }
            receive(observation)
        }
    }

    func play() async throws {
        if let controlError {
            throw controlError
        }
        guard observation.currentItem.managedID != nil else {
            return
        }
        updateObservation(
            HostPlaybackObservation(
                currentItem: observation.currentItem,
                status: .playing
            )
        )
    }

    func pause() {
        guard observation.currentItem.managedID != nil else {
            return
        }
        updateObservation(
            HostPlaybackObservation(
                currentItem: observation.currentItem,
                status: .paused
            )
        )
    }

    func skipToNextEntry() async throws {
        if let controlError {
            throw controlError
        }
        guard let currentItemID = observation.currentItem.managedID,
              let currentIndex = items.firstIndex(where: { $0.id == currentItemID }) else {
            return
        }
        let nextIndex = items.index(after: currentIndex)
        let nextItem = items.indices.contains(nextIndex) ? items[nextIndex] : nil
        updateObservation(
            HostPlaybackObservation(
                currentItem: nextItem.map { .managed($0.id) } ?? .none,
                status: nextItem == nil ? .stopped : .playing
            )
        )
    }

    func endSession() {
        items.removeAll()
        observation = HostPlaybackObservation(
            currentItem: .none,
            status: .stopped
        )
        let continuations = Array(observationContinuations.values)
        observationContinuations.removeAll()
        for continuation in continuations {
            continuation.yield(observation)
            continuation.finish()
        }
    }

    private func updateObservation(_ observation: HostPlaybackObservation) {
        self.observation = observation
        for continuation in observationContinuations.values {
            continuation.yield(observation)
        }
    }
}
#endif
