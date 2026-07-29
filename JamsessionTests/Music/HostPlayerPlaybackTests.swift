import Foundation
import Testing
@testable import Jamsession

@MainActor
struct HostPlayerPlaybackTests {
    private let hostID = ParticipantID("host")
    private let firstID = SubmissionID("submission-A")
    private let secondID = SubmissionID("submission-B")

    @Test
    func playbackStartAndRepeatedCallbacksAdvanceCanonicalStateOnce() async {
        let executor = PlaybackExecutor(
            observation: observation(firstID, status: .stopped)
        )
        let player = HostPlayer(executor: executor)
        let session = makeSession()
        let observationTask = Task {
            await player.observePlaybackTransitions(for: session)
        }
        await waitUntil { executor.observationStartCount == 1 }

        executor.send(observation(firstID, status: .playing))
        executor.send(observation(firstID, status: .playing))
        await waitUntil { session.rotationState.currentlyPlaying?.id == firstID }

        #expect(session.rotationState.currentlyPlaying?.id == firstID)
        #expect(session.rotationState.pending(for: hostID).map(\.id) == [secondID])

        observationTask.cancel()
        await observationTask.value
    }

    @Test
    func completionAndSkipCallbacksEachAdvanceCanonicalStateOnce() async {
        let executor = PlaybackExecutor(
            observation: observation(firstID, status: .stopped)
        )
        let player = HostPlayer(executor: executor)
        let session = makeSession()
        let observationTask = Task {
            await player.observePlaybackTransitions(for: session)
        }
        await waitUntil { executor.observationStartCount == 1 }

        executor.send(observation(firstID, status: .playing))
        await waitUntil { session.rotationState.currentlyPlaying?.id == firstID }

        executor.send(observation(secondID, status: .playing))
        executor.send(observation(secondID, status: .playing))
        await waitUntil { session.rotationState.currentlyPlaying?.id == secondID }
        #expect(session.rotationState.pending(for: hostID).isEmpty)

        let empty = HostPlaybackObservation(currentItem: .none, status: .stopped)
        executor.send(empty)
        executor.send(empty)
        await waitUntil { session.rotationState.currentlyPlaying == nil }

        #expect(session.playbackQueueItems.isEmpty)
        observationTask.cancel()
        await observationTask.value
    }

    @Test
    func oneObserverIsOwnedAndCancellationReachesExecutor() async {
        let executor = PlaybackExecutor(
            observation: HostPlaybackObservation(
                currentItem: .none,
                status: .stopped
            )
        )
        let player = HostPlayer(executor: executor)
        let session = makeEmptySession()
        let observationTask = Task {
            await player.observePlaybackTransitions(for: session)
        }
        await waitUntil { player.isObservingPlayback }

        await player.observePlaybackTransitions(for: session)
        #expect(executor.observationStartCount == 1)

        observationTask.cancel()
        await observationTask.value

        #expect(executor.observationWasCancelled)
        #expect(!player.isObservingPlayback)
    }

    @Test
    func unmanagedCurrentEntryPausesAndSurfacesQueueFailure() async {
        let executor = PlaybackExecutor(
            observation: HostPlaybackObservation(
                currentItem: .unmanaged,
                status: .playing
            )
        )
        let player = HostPlayer(executor: executor)
        let session = makeSession()
        let observationTask = Task {
            await player.observePlaybackTransitions(for: session)
        }

        await waitUntil { player.state == .failed(.queueChanged) }

        #expect(player.state == .failed(.queueChanged))
        #expect(executor.pauseCount == 1)
        #expect(session.rotationState.currentlyPlaying == nil)
        observationTask.cancel()
        await observationTask.value
    }

    @Test
    func playPauseAndSkipUseExecutorBoundary() async {
        let executor = PlaybackExecutor(
            observation: observation(firstID, status: .stopped)
        )
        let player = HostPlayer(executor: executor)

        await player.play()
        player.pause()
        await player.skipCurrentTrack()

        #expect(executor.playCount == 1)
        #expect(executor.pauseCount == 1)
        #expect(executor.skipCount == 1)
    }

    @Test
    func typedControlFailurePausesAndCanRecoverThroughReconciliation() async {
        let executor = PlaybackExecutor(
            observation: observation(firstID, status: .stopped),
            controlError: .offline
        )
        let player = HostPlayer(executor: executor)

        await player.play()
        #expect(player.state == .failed(.offline))
        #expect(executor.pauseCount == 1)

        executor.controlError = nil
        await player.reconcile(with: [])

        #expect(player.state == .idle)
    }

    @Test
    func cancelledControlDoesNotPublishFailure() async throws {
        let executor = PlaybackExecutor(
            observation: observation(firstID, status: .stopped),
            controlDelay: .seconds(10)
        )
        let player = HostPlayer(executor: executor)
        let controlTask = Task {
            await player.play()
        }
        await waitUntil { player.isControlRequestInFlight }

        controlTask.cancel()
        await controlTask.value

        #expect(executor.controlWasCancelled)
        #expect(player.state == .idle)
        #expect(!player.isControlRequestInFlight)
    }

    private func makeSession() -> HostSessionModel {
        let session = makeEmptySession()
        #expect(session.handle(submit("A", id: firstID, event: 1)) == .accepted)
        #expect(session.handle(submit("B", id: secondID, event: 2)) == .accepted)
        return session
    }

    private func makeEmptySession() -> HostSessionModel {
        HostSessionModel(
            sessionName: "Test",
            roomCode: "TEST",
            participants: [
                SessionParticipant(
                    id: hostID,
                    displayName: "Host",
                    emoji: "🎸",
                    colorID: .orange
                )
            ],
            hostID: hostID
        )
    }

    private func submit(
        _ title: String,
        id: SubmissionID,
        event: Int
    ) -> QueueCommand {
        QueueCommand(
            id: FairnessEventID("submit-\(event)"),
            participantID: hostID,
            action: .submit(
                selection: CatalogTrackSelection(
                    id: TrackID("track-\(title)"),
                    title: title,
                    artistName: "Artist"
                ),
                submissionID: id
            )
        )
    }

    private func observation(
        _ itemID: SubmissionID,
        status: HostPlaybackStatus
    ) -> HostPlaybackObservation {
        HostPlaybackObservation(
            currentItem: .managed(itemID),
            status: status
        )
    }

    private func waitUntil(
        _ condition: () -> Bool
    ) async {
        for _ in 0..<100 where !condition() {
            await Task.yield()
        }
    }

    @MainActor
    private final class PlaybackExecutor: HostQueueExecuting {
        var controlError: HostPlaybackError?
        var pauseCount = 0
        var playCount = 0
        var skipCount = 0
        var observationStartCount = 0
        var observationWasCancelled = false
        var controlWasCancelled = false

        private var currentObservation: HostPlaybackObservation
        private var observationContinuation:
            AsyncStream<HostPlaybackObservation>.Continuation?
        private let controlDelay: Duration?

        init(
            observation: HostPlaybackObservation,
            controlError: HostPlaybackError? = nil,
            controlDelay: Duration? = nil
        ) {
            currentObservation = observation
            self.controlError = controlError
            self.controlDelay = controlDelay
        }

        func snapshot() -> PlaybackQueueSnapshot {
            PlaybackQueueSnapshot(items: [])
        }

        func apply(_ plan: QueueReconciliationPlan) async throws {
        }

        func observePlayback(
            _ receive: @escaping @MainActor @Sendable (HostPlaybackObservation) -> Void
        ) async {
            observationStartCount += 1
            let stream = AsyncStream<HostPlaybackObservation> { continuation in
                observationContinuation = continuation
                continuation.yield(currentObservation)
            }
            defer {
                observationWasCancelled = Task.isCancelled
                observationContinuation = nil
            }

            for await observation in stream {
                receive(observation)
            }
        }

        func play() async throws {
            playCount += 1
            try await performControl()
        }

        func pause() {
            pauseCount += 1
        }

        func skipToNextEntry() async throws {
            skipCount += 1
            try await performControl()
        }

        func send(_ observation: HostPlaybackObservation) {
            currentObservation = observation
            observationContinuation?.yield(observation)
        }

        private func performControl() async throws {
            do {
                if let controlDelay {
                    try await Task.sleep(for: controlDelay)
                }
                if let controlError {
                    throw controlError
                }
            } catch is CancellationError {
                controlWasCancelled = true
                throw CancellationError()
            }
        }
    }
}
