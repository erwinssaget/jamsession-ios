nonisolated struct HostLobbyPresentation: Equatable, Sendable {
    let sessionName: String
    let roomCode: String
    let participants: [Participant]

    nonisolated struct Participant: Equatable, Identifiable, Sendable {
        let id: ParticipantID
        let name: String
        let emoji: String
        let colorID: ProfileColorID
        let isHost: Bool
    }
}
