nonisolated struct SessionParticipant: Identifiable, Sendable, Equatable {
    let id: ParticipantID
    let displayName: String
    let emoji: String
    let colorID: ProfileColorID

    init(
        id: ParticipantID,
        displayName: String,
        emoji: String,
        colorID: ProfileColorID
    ) {
        self.id = id
        self.displayName = displayName
        self.emoji = emoji
        self.colorID = colorID
    }
}
