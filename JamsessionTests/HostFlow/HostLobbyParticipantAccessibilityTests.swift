import Testing
@testable import Jamsession

struct HostLobbyParticipantAccessibilityTests {
    @Test
    func hostLabelIncludesHostRole() {
        let participant = makeParticipant(name: "Maya", isHost: true)

        let label = HostLobbyParticipantAccessibility.label(
            for: participant,
            position: 1
        )

        #expect(label == "Position 1, Maya, Host")
    }

    @Test
    func guestLabelDoesNotAnnounceHostRole() {
        let participant = makeParticipant(name: "Leo", isHost: false)

        let label = HostLobbyParticipantAccessibility.label(
            for: participant,
            position: 2
        )

        #expect(label == "Position 2, Leo, Guest")
    }

    private func makeParticipant(
        name: String,
        isHost: Bool
    ) -> HostLobbyPresentation.Participant {
        HostLobbyPresentation.Participant(
            id: ParticipantID(name),
            name: name,
            emoji: "🎧",
            colorID: .purple,
            isHost: isHost
        )
    }
}
