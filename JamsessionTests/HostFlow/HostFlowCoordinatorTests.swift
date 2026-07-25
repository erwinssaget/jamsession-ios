import Testing
@testable import Jamsession

@MainActor
struct HostFlowCoordinatorTests {
    @Test
    func profileMovesToJustInTimeMusicExplanation() {
        let coordinator = makeCoordinator(outcome: .eligible)

        coordinator.submitProfile(profile)

        #expect(coordinator.step == .musicAccess)
        #expect(coordinator.musicAccessState == .explanation)
        #expect(coordinator.profile == profile)
        #expect(coordinator.session == nil)
    }

    @Test
    func eligibleHostCreatesSoloLobbyAndStartsCanonicalSession() async throws {
        let coordinator = makeCoordinator(outcome: .eligible)
        coordinator.submitProfile(profile)

        await coordinator.requestMusicEligibility()

        #expect(coordinator.step == .lobby)
        let session = try #require(coordinator.session)
        #expect(session.participants.count == 1)
        #expect(session.participants.first?.displayName == "Maya")
        #expect(session.participants.first?.emoji == "🎸")
        #expect(session.participants.first?.colorID == .orange)
        #expect(session.rotationState.lockedOrder == [session.hostID])

        let lobby = HostLobbyPresentationMapper.map(session)
        #expect(lobby.participants.count == 1)
        #expect(lobby.participants.first?.isHost == true)

        coordinator.startSession()
        #expect(coordinator.step == .queue)
        #expect(
            session.presentation(viewedBy: session.hostID).participants.first?.isHost == true
        )
    }

    @Test(
        arguments: [
            (
                HostMusicEligibilityOutcome.authorizationDenied,
                HostMusicAccessState.authorizationDenied
            ),
            (
                HostMusicEligibilityOutcome.authorizationRestricted,
                HostMusicAccessState.authorizationRestricted
            ),
            (
                HostMusicEligibilityOutcome.subscriptionRequired,
                HostMusicAccessState.subscriptionRequired
            ),
            (
                HostMusicEligibilityOutcome.unavailable,
                HostMusicAccessState.unavailable
            )
        ]
    )
    func ineligibleOutcomeKeepsHostOutOfLobby(
        outcome: HostMusicEligibilityOutcome,
        expectedState: HostMusicAccessState
    ) async {
        let coordinator = makeCoordinator(outcome: outcome)
        coordinator.submitProfile(profile)

        await coordinator.requestMusicEligibility()

        #expect(coordinator.step == .musicAccess)
        #expect(coordinator.musicAccessState == expectedState)
        #expect(coordinator.session == nil)
    }

    @Test
    func cancelledEligibilityDoesNotCreateSessionOrLeaveLoadingState() async {
        let coordinator = HostFlowCoordinator(
            eligibilityChecker: SlowEligibilityChecker()
        )
        coordinator.submitProfile(profile)

        let request = Task {
            await coordinator.requestMusicEligibility()
        }
        await Task.yield()
        request.cancel()
        await request.value

        #expect(coordinator.step == .musicAccess)
        #expect(coordinator.musicAccessState == .explanation)
        #expect(coordinator.session == nil)
    }

    @Test
    func returningToProfileClearsEphemeralSessionState() async {
        let coordinator = makeCoordinator(outcome: .eligible)
        coordinator.submitProfile(profile)
        await coordinator.requestMusicEligibility()
        #expect(coordinator.session != nil)

        coordinator.returnToProfile()

        #expect(coordinator.step == .profile)
        #expect(coordinator.musicAccessState == .explanation)
        #expect(coordinator.profile == nil)
        #expect(coordinator.session == nil)
    }

    private var profile: ProfileDraft {
        ProfileDraft(
            displayName: "Maya",
            emoji: "🎸",
            colorID: .orange
        )
    }

    private func makeCoordinator(
        outcome: HostMusicEligibilityOutcome
    ) -> HostFlowCoordinator {
        HostFlowCoordinator(
            eligibilityChecker: ImmediateEligibilityChecker(outcome: outcome)
        )
    }

    private struct ImmediateEligibilityChecker: HostMusicEligibilityChecking {
        let outcome: HostMusicEligibilityOutcome

        func requestEligibility() async -> HostMusicEligibilityOutcome {
            outcome
        }
    }

    private struct SlowEligibilityChecker: HostMusicEligibilityChecking {
        func requestEligibility() async -> HostMusicEligibilityOutcome {
            do {
                try await Task.sleep(for: .seconds(10))
                return .eligible
            } catch {
                return .unavailable
            }
        }
    }
}
