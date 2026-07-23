import Testing
@testable import Jamsession

struct FairnessSchedulerTransitionsTests {
    private let scheduler = FairnessScheduler()

    @Test func playbackAdvanceConsumesCurrentAndStartsNextOnce() throws {
        var state = try makeState(tracks: [track("A1", by: a), track("A2", by: a), track("B1", by: b)])
        let firstAdvance = event(10, .advancePlayback)

        state = try scheduler.applyingAccepted(firstAdvance, to: state)
        #expect(state.currentlyPlaying?.title == "A1")
        #expect(scheduler.nextUp(in: state)?.title == "B1")

        let replayed = try scheduler.applyingAccepted(firstAdvance, to: state)
        #expect(replayed == state)

        state = try scheduler.applyingAccepted(event(11, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "B1")
        #expect(scheduler.nextUp(in: state)?.title == "A2")
    }

    @Test func playingTrackSkipRequiresPlaybackAndConsumesTheTrack() throws {
        var state = try makeState(tracks: [track("A1", by: a), track("B1", by: b)])

        #expect(throws: FairnessRejection.nothingPlaying) {
            try scheduler.applyingAccepted(event(10, .hostSkipPlayingTrack), to: state)
        }
        state = try scheduler.applyingAccepted(event(11, .advancePlayback), to: state)
        state = try scheduler.applyingAccepted(event(12, .hostSkipPlayingTrack), to: state)

        #expect(state.currentlyPlaying?.title == "B1")
        #expect(state.pending(for: a).isEmpty)
    }

    @Test func failedTrackIsRemovedWithoutStartingPlaybackAndStopsBlockingDuplicates() throws {
        var state = try makeState(tracks: [track("A1", by: a, trackID: "shared"), track("B1", by: b)])
        state = try scheduler.applyingAccepted(event(10, .failTrack(SubmissionID("A1"))), to: state)

        #expect(state.currentlyPlaying == nil)
        #expect(scheduler.nextUp(in: state)?.title == "B1")
        state = try scheduler.applyingAccepted(event(11, .submit(track("C1", by: c, trackID: "shared"))), to: state)
        #expect(state.pending(for: c).map(\.title) == ["C1"])
    }

    @Test func failedNextUpAdvancesOnceToTheFollowingParticipant() throws {
        var state = try makeState(participants: [a, b, c], tracks: [
            track("A1", by: a), track("A2", by: a),
            track("B1", by: b), track("B2", by: b),
            track("C1", by: c),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "A1")
        #expect(scheduler.nextUp(in: state)?.title == "B1")

        state = try scheduler.applyingAccepted(event(11, .failTrack(SubmissionID("B1"))), to: state)

        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["C1", "A2", "B2"])
        state = try scheduler.applyingAccepted(event(12, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "C1")
    }

    @Test func failedNextUpDoesNotAllowConsecutivePlaybackAfterWrapping() throws {
        var state = try makeState(participants: [a, b], tracks: [
            track("A1", by: a), track("A2", by: a),
            track("B1", by: b), track("B2", by: b),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        state = try scheduler.applyingAccepted(event(11, .failTrack(SubmissionID("B1"))), to: state)

        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["B2", "A2"])
        state = try scheduler.applyingAccepted(event(12, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "B2")
    }

    @Test func currentlyPlayingDoesNotCountTowardCapOrBlockTrackDuplicate() throws {
        var state = try makeState(participants: [a], tracks: [
            track("A1", by: a, trackID: "shared"), track("A2", by: a), track("A3", by: a),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        state = try scheduler.applyingAccepted(event(11, .submit(track("A4", by: a, trackID: "shared"))), to: state)

        #expect(state.currentlyPlaying?.title == "A1")
        #expect(state.pending(for: a).count == 3)
    }

    @Test func goneParticipantIsATombstoneAndCanReturnWithoutDeletedTracks() throws {
        var state = try makeState(tracks: [track("A1", by: a), track("B1", by: b)])
        state = try scheduler.applyingAccepted(event(10, .markGone(a)), to: state)

        #expect(state.lockedOrder == [a, b, c])
        #expect(state.pending(for: a).isEmpty)
        #expect(scheduler.nextUp(in: state)?.title == "B1")

        state = try scheduler.applyingAccepted(event(11, .unmarkGone(a)), to: state)
        #expect(state.status(for: a) == .connected)
        #expect(state.lockedOrder == [a, b, c])
        #expect(state.pending(for: a).isEmpty)
    }

    @Test func removedParticipantIsTerminal() throws {
        var state = try makeState(tracks: [track("A1", by: a), track("B1", by: b)])
        state = try scheduler.applyingAccepted(event(10, .block(a)), to: state)

        #expect(state.status(for: a) == .removed)
        #expect(state.lockedOrder == [a, b, c])
        #expect(throws: FairnessRejection.participantRemoved) {
            try scheduler.applyingAccepted(event(11, .unmarkGone(a)), to: state)
        }
        #expect(throws: FairnessRejection.participantRemoved) {
            try scheduler.applyingAccepted(event(12, .submit(track("A2", by: a))), to: state)
        }
    }

    @Test func markGoneDoesNotStopCurrentlyPlayingTrack() throws {
        var state = try makeState(tracks: [track("A1", by: a), track("A2", by: a), track("B1", by: b)])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        state = try scheduler.applyingAccepted(event(11, .markGone(a)), to: state)

        #expect(state.currentlyPlaying?.title == "A1")
        #expect(state.pending(for: a).isEmpty)
        #expect(scheduler.nextUp(in: state)?.title == "B1")
    }

    @Test func lateJoinAppendsAndParticipatesAtTheTailOfTheCurrentRound() throws {
        let d = ParticipantID("D")
        var state = try makeState(participants: [a, b], tracks: [
            track("A1", by: a), track("A2", by: a), track("B1", by: b),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        state = try scheduler.applyingAccepted(event(11, .addParticipant(d)), to: state)
        state = try scheduler.applyingAccepted(event(12, .submit(track("D1", by: d))), to: state)

        #expect(state.lockedOrder == [a, b, d])
        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["B1", "D1", "A2"])
    }

    @Test func lateJoinAfterOnlyParticipantStartsPlayingGetsTheNextTurn() throws {
        var state = try makeState(participants: [a], tracks: [
            track("A1", by: a), track("A2", by: a),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        #expect(state.cursor == 1)

        state = try scheduler.applyingAccepted(event(11, .addParticipant(b)), to: state)
        state = try scheduler.applyingAccepted(event(12, .submit(track("B1", by: b))), to: state)

        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["B1", "A2"])

        state = try scheduler.applyingAccepted(event(13, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "B1")
    }

    @Test func removingNextUpDuringPlaybackKeepsTheOwnersFollowingTrackAhead() throws {
        var state = try makeState(participants: [a, b], tracks: [
            track("A1", by: a), track("A2", by: a),
            track("B1", by: b), track("B2", by: b),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "A1")
        #expect(scheduler.nextUp(in: state)?.title == "B1")

        state = try scheduler.applyingAccepted(
            event(11, .removeOwn(submissionID: SubmissionID("B1"), participantID: b)),
            to: state
        )

        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["B2", "A2"])
        state = try scheduler.applyingAccepted(event(12, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "B2")
    }

    @Test func reconnectAfterOriginalPositionPassedWaitsForNextRound() throws {
        var state = try makeState(participants: [a, b, c], tracks: [
            track("A1", by: a), track("A2", by: a), track("B1", by: b), track("C1", by: c),
        ])
        state = try scheduler.applyingAccepted(event(10, .advancePlayback), to: state)
        state = try scheduler.applyingAccepted(event(11, .setStatus(participantID: b, status: .reconnecting)), to: state)
        state = try scheduler.applyingAccepted(event(12, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "C1")

        state = try scheduler.applyingAccepted(event(13, .setStatus(participantID: b, status: .connected)), to: state)
        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["A2", "B1"])
    }

    @Test func participantCannotRemoveOrSkipAnotherParticipantsTurn() throws {
        let state = try makeState(tracks: [track("A1", by: a), track("B1", by: b)])

        #expect(throws: FairnessRejection.unauthorizedAction) {
            try scheduler.applyingAccepted(
                event(10, .removeOwn(submissionID: SubmissionID("A1"), participantID: b)),
                to: state
            )
        }
        #expect(throws: FairnessRejection.unauthorizedAction) {
            try scheduler.applyingAccepted(event(11, .skipOwnTurn(participantID: b)), to: state)
        }
    }

    private var a: ParticipantID { FairnessTestSupport.a }
    private var b: ParticipantID { FairnessTestSupport.b }
    private var c: ParticipantID { FairnessTestSupport.c }
    private func track(_ name: String, by participantID: ParticipantID, trackID: String? = nil) -> QueuedTrack {
        FairnessTestSupport.track(name, by: participantID, trackID: trackID)
    }
    private func event(_ number: Int, _ action: FairnessEvent.Action) -> FairnessEvent {
        FairnessTestSupport.event(number, action)
    }
    private func makeState(
        participants: [ParticipantID] = [FairnessTestSupport.a, FairnessTestSupport.b, FairnessTestSupport.c],
        tracks: [QueuedTrack]
    ) throws -> RotationState {
        try FairnessTestSupport.state(participants: participants, tracks: tracks)
    }
}
