nonisolated enum HostMusicEligibilityOutcome: Equatable, Sendable {
    case eligible
    case authorizationDenied
    case authorizationRestricted
    case subscriptionRequired
    case unavailable
}
