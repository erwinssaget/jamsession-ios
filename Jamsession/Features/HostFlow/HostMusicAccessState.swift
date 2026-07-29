nonisolated enum HostMusicAccessState: Equatable, Sendable {
    case explanation
    case checking
    case authorizationDenied
    case authorizationRestricted
    case subscriptionOfferAvailable
    case subscriptionOfferUnavailable
    case subscriptionRequired
    case unavailable
}
