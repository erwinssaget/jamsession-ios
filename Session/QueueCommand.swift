nonisolated struct QueueCommand: Sendable, Equatable {
    nonisolated enum Action: Sendable, Equatable {
        case submit(selection: CatalogTrackSelection, submissionID: SubmissionID)
        case removePending(SubmissionID)
        case skipNextTurn
        case advancePlayback
    }

    let id: FairnessEventID
    let participantID: ParticipantID
    let action: Action

    init(id: FairnessEventID, participantID: ParticipantID, action: Action) {
        self.id = id
        self.participantID = participantID
        self.action = action
    }
}
