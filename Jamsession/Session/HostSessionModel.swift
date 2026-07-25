import Observation

@MainActor
@Observable
final class HostSessionModel {
    let sessionName: String
    let roomCode: String
    let hostID: ParticipantID
    private(set) var participants: [SessionParticipant]
    private(set) var rotationState: RotationState
    private(set) var lastCommandOutcome: QueueCommandOutcome?

    private let scheduler = FairnessScheduler()
    private var commandOutcomes: [FairnessEventID: QueueCommandOutcome] = [:]

    init(
        sessionName: String,
        roomCode: String,
        participants: [SessionParticipant],
        hostID: ParticipantID
    ) {
        self.sessionName = sessionName
        self.roomCode = roomCode
        self.participants = participants
        self.hostID = hostID
        rotationState = RotationState(participants: participants.map(\.id))
    }

    @discardableResult
    func handle(_ command: QueueCommand) -> QueueCommandOutcome {
        if let existing = commandOutcomes[command.id] {
            lastCommandOutcome = existing
            return existing
        }

        let outcome: QueueCommandOutcome
        do {
            let event = try fairnessEvent(for: command)
            try scheduler.apply(event, to: &rotationState)
            outcome = .accepted
        } catch let rejection {
            outcome = .rejected(rejection)
        }

        commandOutcomes[command.id] = outcome
        lastCommandOutcome = outcome
        return outcome
    }

    func dismissLastCommandOutcome() {
        lastCommandOutcome = nil
    }

    func presentation(viewedBy participantID: ParticipantID) -> QueueSessionPresentation {
        QueueSessionPresentationMapper.map(
            sessionName: sessionName,
            roomCode: roomCode,
            participants: participants,
            hostID: hostID,
            viewerID: participantID,
            state: rotationState,
            scheduler: scheduler
        )
    }

    private func fairnessEvent(
        for command: QueueCommand
    ) throws(FairnessRejection) -> FairnessEvent {
        guard rotationState.status(for: command.participantID) != nil else {
            throw FairnessRejection.participantNotFound
        }

        let action: FairnessEvent.Action
        switch command.action {
        case .submit(let selection, let submissionID):
            action = .submit(
                QueuedTrack(
                    id: submissionID,
                    trackID: selection.id,
                    submitterID: command.participantID,
                    title: selection.title,
                    artistName: selection.artistName,
                    isExplicit: selection.isExplicit
                )
            )
        case .removePending(let submissionID):
            action = command.participantID == hostID
                ? .hostRemove(submissionID)
                : .removeOwn(
                    submissionID: submissionID,
                    participantID: command.participantID
                )
        case .skipNextTurn(let expectedSubmissionID):
            guard scheduler.nextUp(in: rotationState)?.id == expectedSubmissionID else {
                throw FairnessRejection.notNextUp
            }
            action = command.participantID == hostID
                ? .hostSkipTurn
                : .skipOwnTurn(participantID: command.participantID)
        case .advancePlayback:
            guard command.participantID == hostID else {
                throw FairnessRejection.unauthorizedAction
            }
            action = .advancePlayback
        }

        return FairnessEvent(id: command.id, action: action)
    }
}
