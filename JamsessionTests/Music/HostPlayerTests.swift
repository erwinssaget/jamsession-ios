import Testing
@testable import Jamsession

@MainActor
struct HostPlayerTests {
    @Test
    func successfulReconciliationPublishesReadyState() async {
        let executor = RecordingQueueExecutor()
        let player = HostPlayer(executor: executor)
        let desired = [item("A")]

        await player.reconcile(with: desired)

        #expect(player.state == .ready)
        #expect(executor.appliedPlans.count == 1)
        #expect(executor.appliedPlans.first?.desiredItems == desired)
        #expect(executor.pauseCount == 0)
    }

    @Test
    func emptyReconciliationPublishesIdleState() async {
        let executor = RecordingQueueExecutor()
        let player = HostPlayer(executor: executor)

        await player.reconcile(with: [])

        #expect(player.state == .idle)
        #expect(executor.appliedPlans.first?.operations.isEmpty == true)
    }

    @Test
    func typedExecutorFailurePausesAndRemainsActionable() async {
        let executor = RecordingQueueExecutor(error: .offline)
        let player = HostPlayer(executor: executor)

        await player.reconcile(with: [item("A")])

        #expect(player.state == .failed(.offline))
        #expect(executor.pauseCount == 1)
    }

    @Test
    func protectedQueueMismatchPausesWithoutCallingExecutor() async {
        let current = item("Current")
        let executor = RecordingQueueExecutor(
            snapshot: PlaybackQueueSnapshot(
                items: [current],
                protectedItemID: current.id
            )
        )
        let player = HostPlayer(executor: executor)

        await player.reconcile(with: [item("Replacement")])

        #expect(player.state == .failed(.queueChanged))
        #expect(executor.appliedPlans.isEmpty)
        #expect(executor.pauseCount == 1)
    }

    @Test
    func supersededFailureCannotPauseOrReplaceNewerReadyState() async throws {
        let executor = SupersededFailureExecutor()
        let player = HostPlayer(executor: executor)

        let oldReconciliation = Task {
            await player.reconcile(with: [item("Old")])
        }
        try await Task.sleep(for: .milliseconds(10))
        await player.reconcile(with: [item("New")])
        await oldReconciliation.value

        #expect(player.state == .ready)
        #expect(executor.pauseCount == 0)
    }

    @Test
    func endSessionSuppressesLateReconciliationAndRejectsNewWork() async throws {
        let executor = SupersededFailureExecutor()
        let player = HostPlayer(executor: executor)
        let reconciliation = Task {
            await player.reconcile(with: [item("Old")])
        }
        try await Task.sleep(for: .milliseconds(10))

        player.endSession()
        await reconciliation.value
        await player.reconcile(with: [item("New")])

        #expect(player.state == .idle)
        #expect(executor.pauseCount == 0)
    }

    private func item(_ name: String) -> PlaybackQueueItem {
        PlaybackQueueItem(
            id: SubmissionID("submission-\(name)"),
            trackID: TrackID("track-\(name)")
        )
    }

    @MainActor
    private final class RecordingQueueExecutor: HostQueueExecuting {
        var appliedPlans: [QueueReconciliationPlan] = []
        var pauseCount = 0
        let currentSnapshot: PlaybackQueueSnapshot
        let error: HostPlaybackError?

        init(
            snapshot: PlaybackQueueSnapshot = PlaybackQueueSnapshot(items: []),
            error: HostPlaybackError? = nil
        ) {
            currentSnapshot = snapshot
            self.error = error
        }

        func snapshot() -> PlaybackQueueSnapshot {
            currentSnapshot
        }

        func apply(_ plan: QueueReconciliationPlan) async throws {
            appliedPlans.append(plan)
            if let error {
                throw error
            }
        }

        func observePlayback(
            _ receive: @escaping @MainActor @Sendable (HostPlaybackObservation) -> Void
        ) async {
            receive(
                HostPlaybackObservation(
                    currentItem: .none,
                    status: .stopped
                )
            )
        }

        func play() async throws {
        }

        func pause() {
            pauseCount += 1
        }

        func skipToNextEntry() async throws {
        }

        func endSession() {
        }
    }

    @MainActor
    private final class SupersededFailureExecutor: HostQueueExecuting {
        var pauseCount = 0

        func snapshot() -> PlaybackQueueSnapshot {
            PlaybackQueueSnapshot(items: [])
        }

        func apply(_ plan: QueueReconciliationPlan) async throws {
            guard plan.desiredItems.first?.id == SubmissionID("submission-Old") else {
                return
            }
            try await Task.sleep(for: .milliseconds(100))
            throw HostPlaybackError.offline
        }

        func observePlayback(
            _ receive: @escaping @MainActor @Sendable (HostPlaybackObservation) -> Void
        ) async {
        }

        func play() async throws {
        }

        func pause() {
            pauseCount += 1
        }

        func skipToNextEntry() async throws {
        }

        func endSession() {
        }
    }
}
