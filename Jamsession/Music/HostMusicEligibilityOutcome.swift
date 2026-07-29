nonisolated enum HostMusicEligibilityOutcome: Equatable, Sendable {
    case eligible
    case authorizationDenied
    case authorizationRestricted
    case subscriptionOfferAvailable
    case subscriptionRequired
    case unavailable
}
