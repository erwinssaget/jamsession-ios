import Testing
@testable import Jamsession

struct MockLobbyParticipantAccessibilityTests {
    @Test @MainActor
    func positionedParticipantIncludesRoleAndStatus() {
        let row = MockLobbyParticipantRow(
            participant: MockLobbyFixtures.participants[0],
            position: 1
        )

        #expect(row.accessibilityDescription == "Position 1, Maya, Host · Ready")
    }

    @Test @MainActor
    func unpositionedParticipantIncludesAdmissionStatus() {
        let row = MockLobbyParticipantRow(
            participant: MockLobbyFixtures.pendingParticipant,
            position: nil
        )

        #expect(row.accessibilityDescription == "Sam, Requesting access")
    }
}
