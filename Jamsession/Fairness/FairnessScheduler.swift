nonisolated struct FairnessScheduler: Sendable {
    func apply(_ event: FairnessEvent, to state: inout RotationState) throws {
        if let outcome = state.eventOutcomes[event.id] {
            if case .rejected(let rejection) = outcome {
                throw rejection
            }
            return
        }

        var next = state
        do {
            try apply(event.action, to: &next)
            next.eventOutcomes[event.id] = .accepted
            state = next
        } catch let rejection as FairnessRejection {
            state.eventOutcomes[event.id] = .rejected(rejection)
            throw rejection
        }
    }

    /// Convenience for constructing known-valid fixture state. Rejections cannot return the
    /// updated outcome cache through this value-returning API; command handling must use `apply(_:to:)`.
    func applyingAccepted(_ event: FairnessEvent, to state: RotationState) throws -> RotationState {
        var next = state
        try apply(event, to: &next)
        return next
    }

    func nextUp(in state: RotationState) -> QueuedTrack? {
        candidate(in: state)?.track
    }

    func upcomingQueue(in state: RotationState) -> [QueuedTrack] {
        var simulation = state
        simulation.currentlyPlaying = nil
        var result: [QueuedTrack] = []

        while let selection = candidate(in: simulation) {
            result.append(selection.track)
            simulation.pendingTracks[selection.participantID]?.removeFirst()
            moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &simulation)
        }

        return result
    }

    private func apply(_ action: FairnessEvent.Action, to state: inout RotationState) throws {
        switch action {
        case .addParticipant(let participantID):
            try addParticipant(participantID, to: &state)
        case .submit(let track):
            try submit(track, to: &state)
        case .removeOwn(let submissionID, let participantID):
            try remove(submissionID, requestedBy: participantID, hostOverride: false, from: &state)
        case .hostRemove(let submissionID):
            try remove(submissionID, requestedBy: nil, hostOverride: true, from: &state)
        case .skipOwnTurn(let participantID):
            try skipTurn(requestedBy: participantID, hostOverride: false, in: &state)
        case .hostSkipTurn:
            try skipTurn(requestedBy: nil, hostOverride: true, in: &state)
        case .advancePlayback:
            try advancePlayback(in: &state)
        case .hostSkipPlayingTrack:
            guard state.currentlyPlaying != nil else {
                throw FairnessRejection.nothingPlaying
            }
            try advancePlayback(in: &state)
        case .failTrack(let submissionID):
            try failTrack(submissionID, in: &state)
        case .setStatus(let participantID, let status):
            try setStatus(status, for: participantID, in: &state)
        case .markGone(let participantID):
            try markGone(participantID, in: &state)
        case .unmarkGone(let participantID):
            try unmarkGone(participantID, in: &state)
        case .block(let participantID):
            try block(participantID, in: &state)
        }
    }

    private func addParticipant(_ participantID: ParticipantID, to state: inout RotationState) throws {
        guard state.statuses[participantID] == nil else {
            throw FairnessRejection.participantAlreadyExists
        }
        state.lockedOrder.append(participantID)
        state.statuses[participantID] = .connected
        state.pendingTracks[participantID] = []
    }

    private func submit(_ track: QueuedTrack, to state: inout RotationState) throws {
        guard let status = state.statuses[track.submitterID] else {
            throw FairnessRejection.participantNotFound
        }
        guard status == .connected else {
            throw status == .removed ? FairnessRejection.participantRemoved : .participantNotActive
        }
        let participantPending = state.pendingTracks[track.submitterID] ?? []
        guard participantPending.count < state.config.maxPendingPerParticipant else {
            throw FairnessRejection.pendingLimitReached(limit: state.config.maxPendingPerParticipant)
        }
        guard !state.pendingTracks.values.joined().contains(where: { $0.id == track.id }) else {
            throw FairnessRejection.duplicate
        }
        guard state.currentlyPlaying?.id != track.id else {
            throw FairnessRejection.duplicate
        }
        if state.config.blocksPendingDuplicates {
            guard !state.pendingTracks.values.joined().contains(where: { $0.trackID == track.trackID }) else {
                throw FairnessRejection.duplicate
            }
        }
        state.pendingTracks[track.submitterID, default: []].append(track)
    }

    private func remove(
        _ submissionID: SubmissionID,
        requestedBy participantID: ParticipantID?,
        hostOverride: Bool,
        from state: inout RotationState
    ) throws {
        guard let owner = owner(of: submissionID, in: state) else {
            throw FairnessRejection.submissionNotFound
        }
        guard hostOverride || owner == participantID else {
            throw FairnessRejection.unauthorizedAction
        }
        let selection = candidate(in: state)
        state.pendingTracks[owner]?.removeAll { $0.id == submissionID }
        if selection?.track.id == submissionID, let selection {
            let ownerStillHasPendingTracks = !(state.pendingTracks[owner]?.isEmpty ?? true)
            if state.currentlyPlaying == nil || !ownerStillHasPendingTracks {
                moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &state)
            }
        }
    }

    private func skipTurn(
        requestedBy participantID: ParticipantID?,
        hostOverride: Bool,
        in state: inout RotationState
    ) throws {
        guard let selection = candidate(in: state) else {
            throw FairnessRejection.notNextUp
        }
        guard hostOverride || selection.participantID == participantID else {
            throw FairnessRejection.unauthorizedAction
        }

        if selection.crossedBoundary {
            state.currentRoundSkips.removeAll()
        }
        state.currentRoundSkips.insert(selection.participantID)
        moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &state)

        if candidate(in: state) == nil {
            state.currentRoundSkips.removeAll()
        }
    }

    private func advancePlayback(in state: inout RotationState) throws {
        state.currentlyPlaying = nil
        guard let selection = candidate(in: state) else {
            return
        }
        state.pendingTracks[selection.participantID]?.removeFirst()
        state.currentlyPlaying = selection.track
        moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &state)
    }

    private func failTrack(_ submissionID: SubmissionID, in state: inout RotationState) throws {
        guard let selection = candidate(in: state), selection.track.id == submissionID else {
            throw FairnessRejection.notNextUp
        }
        state.pendingTracks[selection.participantID]?.removeFirst()
        let ownerStillHasPendingTracks = !(state.pendingTracks[selection.participantID]?.isEmpty ?? true)
        if state.currentlyPlaying == nil || !ownerStillHasPendingTracks {
            moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &state)
        }
    }

    private func setStatus(
        _ status: ParticipantStatus,
        for participantID: ParticipantID,
        in state: inout RotationState
    ) throws {
        guard let currentStatus = state.statuses[participantID] else {
            throw FairnessRejection.participantNotFound
        }
        guard currentStatus != .removed else {
            throw FairnessRejection.participantRemoved
        }
        guard currentStatus != .gone else {
            throw FairnessRejection.participantNotActive
        }
        guard status != .gone && status != .removed else {
            throw FairnessRejection.unauthorizedAction
        }
        state.statuses[participantID] = status
    }

    private func markGone(_ participantID: ParticipantID, in state: inout RotationState) throws {
        guard let status = state.statuses[participantID] else {
            throw FairnessRejection.participantNotFound
        }
        guard status != .removed else {
            throw FairnessRejection.participantRemoved
        }
        let selection = candidate(in: state)
        state.statuses[participantID] = .gone
        state.pendingTracks[participantID] = []
        state.currentRoundSkips.remove(participantID)
        if selection?.participantID == participantID, let selection {
            moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &state)
        }
    }

    private func unmarkGone(_ participantID: ParticipantID, in state: inout RotationState) throws {
        guard let status = state.statuses[participantID] else {
            throw FairnessRejection.participantNotFound
        }
        guard status != .removed else {
            throw FairnessRejection.participantRemoved
        }
        guard status == .gone else {
            throw FairnessRejection.participantNotActive
        }
        state.statuses[participantID] = .connected
    }

    private func block(_ participantID: ParticipantID, in state: inout RotationState) throws {
        guard state.statuses[participantID] != nil else {
            throw FairnessRejection.participantNotFound
        }
        let selection = candidate(in: state)
        state.statuses[participantID] = .removed
        state.pendingTracks[participantID] = []
        state.currentRoundSkips.remove(participantID)
        if selection?.participantID == participantID, let selection {
            moveCursor(after: selection.index, crossedBoundary: selection.crossedBoundary, in: &state)
        }
    }

    private func owner(of submissionID: SubmissionID, in state: RotationState) -> ParticipantID? {
        state.lockedOrder.first { participantID in
            state.pendingTracks[participantID, default: []].contains { $0.id == submissionID }
        }
    }

    nonisolated private struct Candidate: Equatable {
        let participantID: ParticipantID
        let index: Int
        let track: QueuedTrack
        let crossedBoundary: Bool
    }

    private func candidate(in state: RotationState) -> Candidate? {
        guard !state.lockedOrder.isEmpty else { return nil }
        let start = min(state.cursor, state.lockedOrder.count)

        if let candidate = firstCandidate(in: start..<state.lockedOrder.count, state: state, crossedBoundary: false) {
            return candidate
        }

        return firstCandidate(in: 0..<start, state: state, crossedBoundary: true)
    }

    private func firstCandidate(
        in indices: Range<Int>,
        state: RotationState,
        crossedBoundary: Bool
    ) -> Candidate? {
        for index in indices {
            let participantID = state.lockedOrder[index]
            guard state.statuses[participantID] == .connected else { continue }
            if !crossedBoundary && state.currentRoundSkips.contains(participantID) {
                continue
            }
            guard let track = state.pendingTracks[participantID]?.first else { continue }
            return Candidate(
                participantID: participantID,
                index: index,
                track: track,
                crossedBoundary: crossedBoundary
            )
        }
        return nil
    }

    private func moveCursor(after index: Int, crossedBoundary: Bool, in state: inout RotationState) {
        let nextIndex = index + 1
        if crossedBoundary || nextIndex >= state.lockedOrder.count {
            // Preserve a one-past-the-tail cursor so a participant appended before the next
            // selection remains eligible in the current round instead of being skipped by a wrap.
            state.cursor = nextIndex
            state.currentRoundSkips.removeAll()
        } else {
            state.cursor = nextIndex
        }
    }
}
