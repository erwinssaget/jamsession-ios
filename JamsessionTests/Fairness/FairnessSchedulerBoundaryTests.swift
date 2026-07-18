import Testing
@testable import Jamsession

struct FairnessSchedulerBoundaryTests {
    private let scheduler = FairnessScheduler()

    @Test func emptyStateHasNoQueueAndPlaybackAdvanceIsAStableNoOp() throws {
        let state = RotationState()
        let event = FairnessTestSupport.event(1, .advancePlayback)

        let advanced = try scheduler.applying(event, to: state)

        #expect(scheduler.nextUp(in: advanced) == nil)
        #expect(scheduler.upcomingQueue(in: advanced).isEmpty)
        #expect(advanced.currentlyPlaying == nil)
        #expect(try scheduler.applying(event, to: advanced) == advanced)
    }

    @Test func hostCanSkipNextUpWithoutRemovingIt() throws {
        var state = try FairnessTestSupport.state(
            participants: [FairnessTestSupport.a, FairnessTestSupport.b],
            tracks: [
                FairnessTestSupport.track("A1", by: FairnessTestSupport.a),
                FairnessTestSupport.track("B1", by: FairnessTestSupport.b),
            ]
        )

        state = try scheduler.applying(FairnessTestSupport.event(10, .hostSkipTurn), to: state)

        #expect(scheduler.nextUp(in: state)?.title == "B1")
        #expect(state.pending(for: FairnessTestSupport.a).map(\.title) == ["A1"])
    }

    @Test func hostRemovalCanRemoveAnyPendingTrack() throws {
        var state = try FairnessTestSupport.state(
            participants: [FairnessTestSupport.a, FairnessTestSupport.b],
            tracks: [
                FairnessTestSupport.track("A1", by: FairnessTestSupport.a),
                FairnessTestSupport.track("A2", by: FairnessTestSupport.a),
                FairnessTestSupport.track("B1", by: FairnessTestSupport.b),
            ]
        )

        state = try scheduler.applying(
            FairnessTestSupport.event(10, .hostRemove(SubmissionID("A2"))),
            to: state
        )
        #expect(scheduler.upcomingQueue(in: state).map(\.title) == ["A1", "B1"])

        state = try scheduler.applying(
            FairnessTestSupport.event(11, .hostRemove(SubmissionID("A1"))),
            to: state
        )
        #expect(scheduler.nextUp(in: state)?.title == "B1")
    }

    @Test func rejectionDoesNotMutateStateOrConsumeEventIdentity() throws {
        let rejectedEvent = FairnessTestSupport.event(
            10,
            .submit(FairnessTestSupport.track("A4", by: FairnessTestSupport.a))
        )
        var state = try FairnessTestSupport.state(
            participants: [FairnessTestSupport.a],
            tracks: [
                FairnessTestSupport.track("A1", by: FairnessTestSupport.a),
                FairnessTestSupport.track("A2", by: FairnessTestSupport.a),
                FairnessTestSupport.track("A3", by: FairnessTestSupport.a),
            ]
        )
        let beforeRejection = state

        #expect(throws: FairnessRejection.pendingLimitReached(limit: 3)) {
            try scheduler.applying(rejectedEvent, to: state)
        }
        #expect(state == beforeRejection)

        state = try scheduler.applying(FairnessTestSupport.event(11, .advancePlayback), to: state)
        state = try scheduler.applying(rejectedEvent, to: state)
        #expect(state.pending(for: FairnessTestSupport.a).map(\.title) == ["A2", "A3", "A4"])
    }

    @Test func invalidReferencesReturnTypedRejections() throws {
        let unknown = ParticipantID("unknown")
        let state = RotationState(participants: [FairnessTestSupport.a])

        #expect(throws: FairnessRejection.participantNotFound) {
            try scheduler.applying(
                FairnessTestSupport.event(1, .submit(FairnessTestSupport.track("X1", by: unknown))),
                to: state
            )
        }
        #expect(throws: FairnessRejection.submissionNotFound) {
            try scheduler.applying(
                FairnessTestSupport.event(2, .hostRemove(SubmissionID("missing"))),
                to: state
            )
        }
        #expect(throws: FairnessRejection.notNextUp) {
            try scheduler.applying(FairnessTestSupport.event(3, .hostSkipTurn), to: state)
        }
        #expect(throws: FairnessRejection.nothingPlaying) {
            try scheduler.applying(FairnessTestSupport.event(4, .hostSkipPlayingTrack), to: state)
        }
    }

    @Test func acceptedEventsAreIdempotentAcrossEveryMutationFamily() throws {
        let a = FairnessTestSupport.a
        let b = FairnessTestSupport.b
        let c = FairnessTestSupport.c
        let base = try FairnessTestSupport.state(
            participants: [a, b],
            tracks: [
                FairnessTestSupport.track("A1", by: a),
                FairnessTestSupport.track("A2", by: a),
                FairnessTestSupport.track("B1", by: b),
                FairnessTestSupport.track("B2", by: b),
            ]
        )

        try expectReplay(.addParticipant(c), from: base)
        try expectReplay(.submit(FairnessTestSupport.track("A3", by: a)), from: base)
        try expectReplay(.removeOwn(submissionID: SubmissionID("A2"), participantID: a), from: base)
        try expectReplay(.hostRemove(SubmissionID("B2")), from: base)
        try expectReplay(.skipOwnTurn(participantID: a), from: base)
        try expectReplay(.hostSkipTurn, from: base)
        try expectReplay(.advancePlayback, from: base)
        try expectReplay(.failTrack(SubmissionID("A1")), from: base)
        try expectReplay(.setStatus(participantID: b, status: .reconnecting), from: base)
        try expectReplay(.markGone(b), from: base)
        try expectReplay(.block(b), from: base)

        let playing = try scheduler.applying(FairnessTestSupport.event(50, .advancePlayback), to: base)
        try expectReplay(.hostSkipPlayingTrack, from: playing)

        let gone = try scheduler.applying(FairnessTestSupport.event(51, .markGone(b)), to: base)
        try expectReplay(.unmarkGone(b), from: gone)
    }

    private func expectReplay(_ action: FairnessEvent.Action, from state: RotationState) throws {
        let event = FairnessEvent(id: FairnessEventID("replay-\(String(describing: action))"), action: action)
        let appliedOnce = try scheduler.applying(event, to: state)
        let appliedTwice = try scheduler.applying(event, to: appliedOnce)

        #expect(appliedTwice == appliedOnce)
    }
}
