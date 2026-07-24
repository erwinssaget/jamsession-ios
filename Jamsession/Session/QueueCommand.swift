nonisolated struct QueueCommand: Sendable, Equatable {
    nonisolated enum Action: Sendable, Equatable {
        case submit(selection: CatalogTrackSelection, submissionID: SubmissionID)
        case removePending(SubmissionID)
        case skipNextTurn
        case advancePlayback
    }

    let id: FairnessEventID
    /// The authenticated actor supplied by the trusted command boundary.
    /// A peer-provided participant claim must be validated before constructing this value.
    let participantID: ParticipantID
    let action: Action

    init(id: FairnessEventID, participantID: ParticipantID, action: Action) {
        self.id = id
        self.participantID = participantID
        self.action = action
    }
}
