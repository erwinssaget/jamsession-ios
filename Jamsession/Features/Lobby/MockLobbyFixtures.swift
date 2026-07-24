import Foundation

nonisolated enum MockLobbyFixtures {
    static let participants = [
        MockLobbyParticipant(
            id: MockFixtureID.mayaParticipant,
            name: "Maya",
            emoji: "🎸",
            detailKey: "mockLobby.participant.host"
        ),
        MockLobbyParticipant(
            id: MockFixtureID.currentParticipant,
            name: "You",
            emoji: "🪩",
            detailKey: "mockLobby.participant.you"
        ),
        MockLobbyParticipant(
            id: MockFixtureID.jordanParticipant,
            name: "Jordan",
            emoji: "🎧",
            detailKey: "mockLobby.participant.ready"
        )
    ]

    static let pendingParticipant = MockLobbyParticipant(
        id: MockFixtureID.samParticipant,
        name: "Sam",
        emoji: "🥁",
        detailKey: "mockLobby.participant.requesting"
    )
}
