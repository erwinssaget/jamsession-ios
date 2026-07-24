import Testing
@testable import Jamsession

struct MockFixtureIdentityTests {
    @Test
    func participantFixturesUseStableSharedIdentity() {
        let queueParticipants = MockSessionFixtures.populated.participants
        let lobbyParticipants = MockLobbyFixtures.participants

        #expect(queueParticipants.map(\.id) == [
            MockFixtureID.mayaParticipant,
            MockFixtureID.currentParticipant,
            MockFixtureID.jordanParticipant
        ])
        #expect(lobbyParticipants.map(\.id) == queueParticipants.map(\.id))
        #expect(MockLobbyFixtures.pendingParticipant.id == MockFixtureID.samParticipant)
    }

    @Test
    func trackFixturesUseStableIdentityAcrossQueueAndSearch() {
        let queue = MockSessionFixtures.populated
        let queueTrackIDs = [queue.nowPlaying?.id].compactMap(\.self) + queue.upcoming.map(\.id)

        #expect(queueTrackIDs == [
            MockFixtureID.midnightDriveTrack,
            MockFixtureID.goldenHourTrack,
            MockFixtureID.afterglowTrack,
            MockFixtureID.sideStreetsTrack,
            MockFixtureID.electricBlueTrack
        ])
        #expect(MockSearchFixtures.tracks.map(\.id) == [
            MockFixtureID.goldenHourTrack,
            MockFixtureID.afterglowTrack,
            MockFixtureID.electricBlueTrack
        ])
    }

    @Test
    func fixtureIDsAreUniqueWithinTheirIdentityDomains() {
        let participantIDs = Set(MockLobbyFixtures.participants.map(\.id) + [
            MockLobbyFixtures.pendingParticipant.id
        ])
        let trackIDs = Set(
            [MockSessionFixtures.populated.nowPlaying?.id].compactMap(\.self)
                + MockSessionFixtures.populated.upcoming.map(\.id)
        )

        #expect(participantIDs.count == 4)
        #expect(trackIDs.count == 5)
        #expect(participantIDs.isDisjoint(with: trackIDs))
    }
}
