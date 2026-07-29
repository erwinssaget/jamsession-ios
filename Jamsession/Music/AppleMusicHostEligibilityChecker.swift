@preconcurrency import MusicKit

nonisolated struct AppleMusicHostEligibilityChecker: HostMusicEligibilityChecking {
    func requestEligibility() async -> HostMusicEligibilityOutcome {
        let authorization = await MusicAuthorization.request()
        guard !Task.isCancelled else {
            return .unavailable
        }

        switch authorization {
        case .authorized:
            break
        case .denied:
            return .authorizationDenied
        case .restricted:
            return .authorizationRestricted
        case .notDetermined:
            return .unavailable
        @unknown default:
            return .unavailable
        }

        do {
            let subscription = try await MusicSubscription.current
            guard !Task.isCancelled else {
                return .unavailable
            }
            if subscription.canPlayCatalogContent {
                return .eligible
            }
            return subscription.canBecomeSubscriber
                ? .subscriptionOfferAvailable
                : .subscriptionRequired
        } catch {
            return .unavailable
        }
    }
}
