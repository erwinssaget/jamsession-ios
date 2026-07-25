@MainActor
enum HostLobbyPresentationMapper {
    static func map(_ session: HostSessionModel) -> HostLobbyPresentation {
        HostLobbyPresentation(
            sessionName: session.sessionName,
            roomCode: session.roomCode,
            participants: session.participants.map { participant in
                HostLobbyPresentation.Participant(
                    id: participant.id,
                    name: participant.displayName,
                    emoji: participant.emoji,
                    colorID: participant.colorID,
                    isHost: participant.id == session.hostID
                )
            }
        )
    }
}
