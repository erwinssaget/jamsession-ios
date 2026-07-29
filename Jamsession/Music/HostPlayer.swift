import Observation

@MainActor
@Observable
final class HostPlayer {
    private(set) var state = HostPlaybackState.idle
    private(set) var playbackStatus = HostPlaybackStatus.stopped
    private(set) var currentItemID: SubmissionID?
    private(set) var isObservingPlayback = false
    private(set) var isControlRequestInFlight = false

    private let executor: any HostQueueExecuting
    private let planner = QueueReconciliationPlanner()
    private var reconciliationID = 0
    private var transitionDeduplicator = PlaybackTransitionDeduplicator()

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

    func observePlaybackTransitions(for session: HostSessionModel) async {
        guard !isObservingPlayback else {
            return
        }

        isObservingPlayback = true
        transitionDeduplicator = PlaybackTransitionDeduplicator()
        defer {
            isObservingPlayback = false
        }

        await executor.observePlayback { [weak self, weak session] observation in
            guard let self, let session, !Task.isCancelled else {
                return
            }
            self.receive(observation, session: session)
        }
    }

    func play() async {
        await performControl {
            try await executor.play()
        }
    }

    func pause() {
        guard !isControlRequestInFlight else {
            return
        }
        executor.pause()
    }

    func skipCurrentTrack() async {
        await performControl {
            try await executor.skipToNextEntry()
        }
    }

    private func receive(
        _ observation: HostPlaybackObservation,
        session: HostSessionModel
    ) {
        playbackStatus = observation.status
        currentItemID = observation.currentItem.managedID

        guard observation.currentItem != .unmanaged else {
            failForQueueMismatch()
            return
        }

        if let observedItemID = observation.currentItem.managedID {
            let canonicalCurrentItemID = session.rotationState.currentlyPlaying?.id
            guard observedItemID == canonicalCurrentItemID
                    || observedItemID == session.nextPlaybackItemID else {
                failForQueueMismatch()
                return
            }
        }

        guard let transition = transitionDeduplicator.transition(
            for: observation,
            canonicalCurrentItemID: session.rotationState.currentlyPlaying?.id,
            canonicalNextItemID: session.nextPlaybackItemID
        ) else {
            return
        }

        let outcome = session.handle(
            QueueCommand(
                id: transition.commandID,
                participantID: session.hostID,
                action: .advancePlayback
            )
        )
        if case .rejected = outcome {
            failForQueueMismatch()
        }
    }

    private func failForQueueMismatch() {
        executor.pause()
        state = .failed(.queueChanged)
    }

    private func performControl(
        _ operation: () async throws -> Void
    ) async {
        guard !isControlRequestInFlight else {
            return
        }

        isControlRequestInFlight = true
        defer {
            isControlRequestInFlight = false
        }

        do {
            try await operation()
        } catch is CancellationError {
            return
        } catch let error as HostPlaybackError {
            executor.pause()
            state = .failed(error)
        } catch {
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
