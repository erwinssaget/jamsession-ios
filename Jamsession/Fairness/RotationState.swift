nonisolated struct RotationState: Sendable, Equatable {
    let config: FairnessConfig
    var lockedOrder: [ParticipantID]
    var statuses: [ParticipantID: ParticipantStatus]
    var pendingTracks: [ParticipantID: [QueuedTrack]]
    var cursor: Int
    var currentRoundSkips: Set<ParticipantID>
    var currentlyPlaying: QueuedTrack?
    var appliedEventIDs: Set<FairnessEventID>

    init(participants: [ParticipantID] = [], config: FairnessConfig = FairnessConfig()) {
        precondition(Set(participants).count == participants.count)
        self.config = config
        lockedOrder = participants
        statuses = Dictionary(uniqueKeysWithValues: participants.map { ($0, .connected) })
        pendingTracks = Dictionary(uniqueKeysWithValues: participants.map { ($0, []) })
        cursor = 0
        currentRoundSkips = []
        currentlyPlaying = nil
        appliedEventIDs = []
    }

    func status(for participantID: ParticipantID) -> ParticipantStatus? {
        statuses[participantID]
    }

    func pending(for participantID: ParticipantID) -> [QueuedTrack] {
        pendingTracks[participantID] ?? []
    }
}
