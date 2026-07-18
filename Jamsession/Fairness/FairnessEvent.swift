nonisolated struct FairnessEvent: Sendable, Equatable {
    nonisolated enum Action: Sendable, Equatable {
        case addParticipant(ParticipantID)
        case submit(QueuedTrack)
        case removeOwn(submissionID: SubmissionID, participantID: ParticipantID)
        case hostRemove(SubmissionID)
        case skipOwnTurn(participantID: ParticipantID)
        case hostSkipTurn
        case advancePlayback
        case hostSkipPlayingTrack
        case failTrack(SubmissionID)
        case setStatus(participantID: ParticipantID, status: ParticipantStatus)
        case markGone(ParticipantID)
        case unmarkGone(ParticipantID)
        case block(ParticipantID)
    }

    let id: FairnessEventID
    let action: Action

    init(id: FairnessEventID, action: Action) {
        self.id = id
        self.action = action
    }
}
