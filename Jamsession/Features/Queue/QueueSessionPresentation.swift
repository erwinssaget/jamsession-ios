nonisolated struct QueueSessionPresentation: Equatable, Sendable {
    let sessionName: String
    let roomCode: String
    let participants: [Participant]
    let nowPlaying: Track?
    let upcoming: [Track]
    let connectionStatus: ConnectionStatus

    nonisolated struct Participant: Equatable, Identifiable, Sendable {
        let id: ParticipantID
        let name: String
        let emoji: String
        let colorID: ProfileColorID
        let isCurrentUser: Bool
        let isHost: Bool
        let status: ParticipantStatus
    }

    nonisolated struct Track: Equatable, Identifiable, Sendable {
        let id: SubmissionID
        let catalogID: TrackID
        let title: String
        let artist: String
        let submitter: Participant
        let isExplicit: Bool
        let canRemove: Bool
        let canSkipTurn: Bool
    }

    nonisolated enum ConnectionStatus: Equatable, Sendable {
        case connected
        case reconnecting
    }
}
