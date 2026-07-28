import Testing
@testable import Jamsession

@MainActor
struct HostSessionModelTests {
    private let hostID = ParticipantID("host")
    private let guestID = ParticipantID("guest")

    @Test
    func commandsDriveTheRealSchedulerAndPresentationMapper() {
        let model = makeModel()

        #expect(model.handle(submit("A1", by: hostID, event: 1)) == .accepted)
        #expect(model.handle(submit("A2", by: hostID, event: 2)) == .accepted)
        #expect(model.handle(submit("B1", by: guestID, event: 3)) == .accepted)

        let presentation = model.presentation(viewedBy: hostID)
        #expect(presentation.upcoming.map(\.title) == ["A1", "B1", "A2"])
        #expect(presentation.upcoming.allSatisfy { $0.canRemove })
        #expect(presentation.upcoming.first?.canSkipTurn == true)
    }

    @Test
    func duplicateAndPendingLimitReturnTypedRejectionsWithoutDivergingPresentation() {
        let model = makeModel()

        #expect(model.handle(submit("A1", by: hostID, event: 1)) == .accepted)
        let duplicate = QueueCommand(
            id: FairnessEventID("event-2"),
            participantID: guestID,
            action: .submit(
                selection: selection("A1"),
                submissionID: SubmissionID("duplicate-submission")
            )
        )
        #expect(model.handle(duplicate) == .rejected(.duplicate))

        #expect(model.handle(submit("A2", by: hostID, event: 3)) == .accepted)
        #expect(model.handle(submit("A3", by: hostID, event: 4)) == .accepted)
        #expect(
            model.handle(submit("A4", by: hostID, event: 5))
                == .rejected(.pendingLimitReached(limit: 3))
        )
        #expect(model.presentation(viewedBy: hostID).upcoming.map(\.title) == ["A1", "A2", "A3"])
    }

    @Test
    func replayedCommandReturnsItsOriginalOutcomeAndMutatesOnce() {
        let model = makeModel()
        let command = submit("A1", by: hostID, event: 1)

        #expect(model.handle(command) == .accepted)
        #expect(model.handle(command) == .accepted)
        #expect(model.rotationState.pending(for: hostID).count == 1)
    }

    @Test
    func guestCannotRemoveAnotherParticipantsTrack() throws {
        let model = makeModel()
        let command = submit("A1", by: hostID, event: 1)
        #expect(model.handle(command) == .accepted)
        let submissionID = try #require(model.rotationState.pending(for: hostID).first?.id)

        let removal = QueueCommand(
            id: FairnessEventID("event-2"),
            participantID: guestID,
            action: .removePending(submissionID)
        )

        #expect(model.handle(removal) == .rejected(.unauthorizedAction))
        #expect(model.rotationState.pending(for: hostID).map(\.title) == ["A1"])
    }

    @Test
    func hostTurnSkipKeepsTheTrackAndMovesItToTheNextRound() {
        let model = makeModel()
        #expect(model.handle(submit("A1", by: hostID, event: 1)) == .accepted)
        #expect(model.handle(submit("B1", by: guestID, event: 2)) == .accepted)

        let skip = QueueCommand(
            id: FairnessEventID("event-3"),
            participantID: hostID,
            action: .skipNextTurn(
                expectedSubmissionID: SubmissionID("submission-A1")
            )
        )
        #expect(model.handle(skip) == .accepted)

        let presentation = model.presentation(viewedBy: hostID)
        #expect(presentation.upcoming.map(\.title) == ["B1", "A1"])
        #expect(model.rotationState.pending(for: hostID).map(\.title) == ["A1"])
    }

    @Test
    func staleTurnSkipDoesNotSkipTheReplacementNextTrack() {
        let model = makeModel()
        #expect(model.handle(submit("A1", by: hostID, event: 1)) == .accepted)
        #expect(model.handle(submit("A2", by: hostID, event: 2)) == .accepted)
        #expect(model.handle(submit("B1", by: guestID, event: 3)) == .accepted)

        let displayedSubmissionID = model.presentation(viewedBy: hostID).upcoming[0].id
        let removal = QueueCommand(
            id: FairnessEventID("event-4"),
            participantID: hostID,
            action: .removePending(displayedSubmissionID)
        )
        #expect(model.handle(removal) == .accepted)
        #expect(model.presentation(viewedBy: hostID).upcoming.map(\.title) == ["B1", "A2"])

        let staleSkip = QueueCommand(
            id: FairnessEventID("event-5"),
            participantID: hostID,
            action: .skipNextTurn(
                expectedSubmissionID: displayedSubmissionID
            )
        )
        #expect(model.handle(staleSkip) == .rejected(.notNextUp))
        #expect(model.presentation(viewedBy: hostID).upcoming.map(\.title) == ["B1", "A2"])
        #expect(model.rotationState.currentRoundSkips.isEmpty)
    }

    @Test
    func guestPresentationExposesOnlyAuthorizedQueueActions() {
        let model = makeModel()
        #expect(model.handle(submit("A1", by: hostID, event: 1)) == .accepted)
        #expect(model.handle(submit("B1", by: guestID, event: 2)) == .accepted)

        let presentation = model.presentation(viewedBy: guestID)
        #expect(presentation.upcoming[0].canRemove == false)
        #expect(presentation.upcoming[0].canSkipTurn == false)
        #expect(presentation.upcoming[1].canRemove == true)
    }

    private func makeModel() -> HostSessionModel {
        HostSessionModel(
            sessionName: "Test Session",
            roomCode: "TEST",
            participants: [
                SessionParticipant(
                    id: hostID,
                    displayName: "Host",
                    emoji: "🎸",
                    colorID: .orange
                ),
                SessionParticipant(
                    id: guestID,
                    displayName: "Guest",
                    emoji: "🎧",
                    colorID: .green
                )
            ],
            hostID: hostID
        )
    }

    private func submit(
        _ name: String,
        by participantID: ParticipantID,
        event: Int
    ) -> QueueCommand {
        QueueCommand(
            id: FairnessEventID("event-\(event)"),
            participantID: participantID,
            action: .submit(
                selection: selection(name),
                submissionID: SubmissionID("submission-\(name)")
            )
        )
    }

    private func selection(_ name: String) -> CatalogTrackSelection {
        CatalogTrackSelection(
            id: TrackID("track-\(name)"),
            title: name,
            artistName: "Artist"
        )
    }
}
