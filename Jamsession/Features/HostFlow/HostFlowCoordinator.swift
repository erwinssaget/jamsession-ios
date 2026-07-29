import Foundation
import Observation

@MainActor
@Observable
final class HostFlowCoordinator {
    private(set) var step = HostFlowStep.profile
    private(set) var musicAccessState = HostMusicAccessState.explanation
    private(set) var profile: ProfileDraft?
    private(set) var session: HostSessionModel?

    private let eligibilityChecker: any HostMusicEligibilityChecking
    private var eligibilityRequestID: UUID?

    init(eligibilityChecker: any HostMusicEligibilityChecking) {
        self.eligibilityChecker = eligibilityChecker
    }

    func submitProfile(_ profile: ProfileDraft) {
        self.profile = profile
        musicAccessState = .explanation
        step = .musicAccess
    }

    func requestMusicEligibility() async {
        guard step == .musicAccess, profile != nil else {
            return
        }

        let requestID = UUID()
        eligibilityRequestID = requestID
        musicAccessState = .checking

        let outcome = await eligibilityChecker.requestEligibility()
        guard eligibilityRequestID == requestID else {
            return
        }
        guard !Task.isCancelled else {
            musicAccessState = .explanation
            eligibilityRequestID = nil
            return
        }

        eligibilityRequestID = nil
        apply(outcome)
    }

    func returnToProfile() {
        eligibilityRequestID = nil
        musicAccessState = .explanation
        session = nil
        profile = nil
        step = .profile
    }

    func startSession() {
        guard step == .lobby, session != nil else {
            return
        }
        step = .queue
    }

    func subscriptionOfferLoadFailed() {
        guard step == .musicAccess,
              musicAccessState == .subscriptionOfferAvailable
                || musicAccessState == .subscriptionOfferUnavailable else {
            return
        }
        musicAccessState = .subscriptionOfferUnavailable
    }

    func returnToLobby() {
        guard session != nil else {
            return
        }
        step = .lobby
    }

    private func apply(_ outcome: HostMusicEligibilityOutcome) {
        switch outcome {
        case .eligible:
            createSoloSession()
            step = .lobby
        case .authorizationDenied:
            musicAccessState = .authorizationDenied
        case .authorizationRestricted:
            musicAccessState = .authorizationRestricted
        case .subscriptionOfferAvailable:
            musicAccessState = .subscriptionOfferAvailable
        case .subscriptionRequired:
            musicAccessState = .subscriptionRequired
        case .unavailable:
            musicAccessState = .unavailable
        }
    }

    private func createSoloSession() {
        guard let profile else {
            return
        }

        let hostID = ParticipantID(UUID().uuidString)
        let sessionName = String(
            localized: "host.session.defaultName",
            defaultValue: "\(profile.displayName)’s Session"
        )
        let roomCode = String(UUID().uuidString.prefix(4)).uppercased()

        session = HostSessionModel(
            sessionName: sessionName,
            roomCode: roomCode,
            participants: [
                SessionParticipant(
                    id: hostID,
                    displayName: profile.displayName,
                    emoji: profile.emoji,
                    colorID: profile.colorID
                )
            ],
            hostID: hostID
        )
    }
}
