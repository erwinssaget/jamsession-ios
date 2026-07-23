import Testing
@testable import Jamsession

struct FairnessSchedulerExamplesTests {
    private let scheduler = FairnessScheduler()

    @Test func equalSupplyInterleavesByRound() throws {
        let tracks = [
            track("A1", by: a), track("A2", by: a),
            track("B1", by: b), track("B2", by: b),
            track("C1", by: c), track("C2", by: c),
        ]
        let state = try makeState(tracks: tracks)

        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["A1", "B1", "C1", "A2", "B2", "C2"])
    }

    @Test func unevenSupplyDoesNotWaitForEmptyParticipant() throws {
        let tracks = [track("A1", by: a), track("A2", by: a), track("A3", by: a), track("B1", by: b)]
        let state = try makeState(participants: [a, b], tracks: tracks)

        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["A1", "B1", "A2", "A3"])
    }

    @Test func hostUsesTheSameCapAndRotationRules() throws {
        var state = try makeState(participants: [a, b], tracks: [
            track("A1", by: a), track("A2", by: a), track("A3", by: a), track("B1", by: b),
        ])

        #expect(throws: FairnessRejection.pendingLimitReached(limit: 3)) {
            try scheduler.applyingAccepted(event(20, .submit(track("A4", by: a))), to: state)
        }
        state = try scheduler.applyingAccepted(event(21, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "A1")
        #expect(scheduler.nextUp(in: state)?.title == "B1")
    }

    @Test func reconnectingGoneRemovedAndEmptyParticipantsAreSkipped() throws {
        let d = ParticipantID("D")
        var state = try makeState(participants: [a, b, c, d], tracks: [
            track("B1", by: b), track("C1", by: c), track("D1", by: d),
        ])
        state = try scheduler.applyingAccepted(event(10, .setStatus(participantID: b, status: .reconnecting)), to: state)
        state = try scheduler.applyingAccepted(event(11, .markGone(c)), to: state)
        state = try scheduler.applyingAccepted(event(12, .block(d)), to: state)

        #expect(scheduler.nextUp(in: state) == nil)
        #expect(state.lockedOrder == [a, b, c, d])
    }

    @Test func turnSkipRetainsTrackCapAndDuplicateUntilNextRound() throws {
        var state = try makeState(participants: [a, b], tracks: [
            track("A1", by: a, trackID: "same"), track("A2", by: a), track("A3", by: a), track("B1", by: b),
        ])
        state = try scheduler.applyingAccepted(event(10, .skipOwnTurn(participantID: a)), to: state)

        #expect(scheduler.nextUp(in: state)?.title == "B1")
        #expect(state.pending(for: a).first?.title == "A1")
        #expect(throws: FairnessRejection.pendingLimitReached(limit: 3)) {
            try scheduler.applyingAccepted(event(11, .submit(track("A4", by: a))), to: state)
        }
        #expect(throws: FairnessRejection.duplicate) {
            try scheduler.applyingAccepted(event(12, .submit(track("B2", by: b, trackID: "same"))), to: state)
        }
        state = try scheduler.applyingAccepted(event(13, .advancePlayback), to: state)
        #expect(state.currentlyPlaying?.title == "B1")
        #expect(scheduler.nextUp(in: state)?.title == "A1")
    }

    @Test func twoSkipsClearAtRoundBoundary() throws {
        var state = try makeState(participants: [a, b], tracks: [track("A1", by: a), track("B1", by: b)])
        state = try scheduler.applyingAccepted(event(10, .skipOwnTurn(participantID: a)), to: state)
        state = try scheduler.applyingAccepted(event(11, .skipOwnTurn(participantID: b)), to: state)

        #expect(state.currentRoundSkips.isEmpty)
        #expect(scheduler.nextUp(in: state)?.title == "A1")
    }

    @Test func loneParticipantSkipDoesNotCreateSilence() throws {
        var state = try makeState(participants: [a], tracks: [track("A1", by: a)])
        state = try scheduler.applyingAccepted(event(10, .skipOwnTurn(participantID: a)), to: state)

        #expect(scheduler.nextUp(in: state)?.title == "A1")
        #expect(state.currentRoundSkips.isEmpty)
    }

    @Test func removingNextUpAdvancesToTheNextParticipant() throws {
        var state = try makeState(participants: [a, b], tracks: [
            track("A1", by: a), track("A2", by: a), track("B1", by: b),
        ])
        state = try scheduler.applyingAccepted(event(10, .removeOwn(submissionID: SubmissionID("A1"), participantID: a)), to: state)

        #expect(scheduler.nextUp(in: state)?.title == "B1")
        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["B1", "A2"])
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
