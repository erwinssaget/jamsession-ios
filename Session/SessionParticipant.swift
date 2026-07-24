nonisolated struct SessionParticipant: Identifiable, Sendable, Equatable {
    let id: ParticipantID
    let displayName: String
    let emoji: String
    let colorID: ProfileColorID
    let isHost: Bool

    init(
        id: ParticipantID,
        displayName: String,
        emoji: String,
        colorID: ProfileColorID,
        isHost: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.emoji = emoji
        self.colorID = colorID
        self.isHost = isHost
    }
}
