import Foundation
import Testing
@testable import Jamsession

struct MockFixtureIdentityTests {
    @Test
    func participantFixturesUseStableSharedIdentity() {
        let queueParticipants = MockSessionFixtures.populated.participants
        let lobbyParticipants = MockLobbyFixtures.participants

        #expect(queueParticipants.map(\.id.rawValue) == [
            MockFixtureID.mayaParticipant.uuidString,
            MockFixtureID.currentParticipant.uuidString,
            MockFixtureID.jordanParticipant.uuidString
        ])
        #expect(lobbyParticipants.map(\.id.uuidString) == queueParticipants.map(\.id.rawValue))
        #expect(MockLobbyFixtures.pendingParticipant.id == MockFixtureID.samParticipant)
    }

    @Test
    func trackFixturesUseStableIdentityAcrossQueueAndSearch() {
        let queue = MockSessionFixtures.populated
        let queueTrackIDs = (
            [queue.nowPlaying?.id].compactMap(\.self) + queue.upcoming.map(\.id)
        ).map(\.rawValue)

        #expect(queueTrackIDs == [
            MockFixtureID.midnightDriveTrack.uuidString,
            MockFixtureID.goldenHourTrack.uuidString,
            MockFixtureID.afterglowTrack.uuidString,
            MockFixtureID.sideStreetsTrack.uuidString,
            MockFixtureID.electricBlueTrack.uuidString
        ])
        #expect(MockSearchFixtures.tracks.map(\.id) == [
            MockFixtureID.goldenHourTrack,
            MockFixtureID.afterglowTrack,
            MockFixtureID.electricBlueTrack,
            MockFixtureID.longTitleTrack
        ])
        #expect(
            MockSessionFixtures.longTitleTrack.id.rawValue
                == MockFixtureID.longTitleTrack.uuidString
        )
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
        #expect(
            Set(participantIDs.map(\.uuidString))
                .isDisjoint(with: Set(trackIDs.map(\.rawValue)))
        )
    }

    @Test
    func fullSessionUsesEightUniqueParticipantIdentities() {
        let participants = MockSessionFixtures.fullSession.participants

        #expect(participants.count == 8)
        #expect(Set(participants.map(\.id)).count == 8)
    }
}
