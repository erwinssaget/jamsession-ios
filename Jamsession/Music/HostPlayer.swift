import Observation

@MainActor
@Observable
final class HostPlayer {
    private(set) var state = HostPlaybackState.idle

    private let executor: any HostQueueExecuting
    private let planner = QueueReconciliationPlanner()
    private var reconciliationID = 0

    init(executor: any HostQueueExecuting) {
        self.executor = executor
    }

    func reconcile(with desiredItems: [PlaybackQueueItem]) async {
        reconciliationID += 1
        let requestID = reconciliationID
        state = .reconciling

        do {
            let plan = try planner.plan(
                from: executor.snapshot(),
                to: desiredItems
            )
            try await executor.apply(plan)
            guard reconciliationID == requestID, !Task.isCancelled else {
                return
            }
            state = desiredItems.isEmpty ? .idle : .ready
        } catch is CancellationError {
            return
        } catch let error as QueueReconciliationPlanningError {
            guard reconciliationID == requestID, !Task.isCancelled else {
                return
            }
            executor.pause()
            state = .failed(map(error))
        } catch let error as HostPlaybackError {
            guard reconciliationID == requestID, !Task.isCancelled else {
                return
            }
            executor.pause()
            state = .failed(error)
        } catch {
            guard reconciliationID == requestID, !Task.isCancelled else {
                return
            }
            executor.pause()
            state = .failed(.unavailable)
        }
    }

    private func map(
        _ error: QueueReconciliationPlanningError
    ) -> HostPlaybackError {
        switch error {
        case .duplicateItemIdentity, .protectedItemMismatch:
            .queueChanged
        }
    }
}
