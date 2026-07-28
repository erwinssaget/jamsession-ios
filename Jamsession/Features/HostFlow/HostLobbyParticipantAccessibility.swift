import Foundation

nonisolated enum HostLobbyParticipantAccessibility {
    static func label(
        for participant: HostLobbyPresentation.Participant,
        position: Int
    ) -> String {
        if participant.isHost {
            String(
                localized: "host.lobby.participant.accessibility",
                defaultValue: "Position \(position), \(participant.name), Host"
            )
        } else {
            String(
                localized: "host.lobby.participant.guest.accessibility",
                defaultValue: "Position \(position), \(participant.name), Guest"
            )
        }
    }
}
