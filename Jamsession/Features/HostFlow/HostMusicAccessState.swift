nonisolated enum HostMusicAccessState: Equatable, Sendable {
    case explanation
    case checking
    case authorizationDenied
    case authorizationRestricted
    case subscriptionRequired
    case unavailable
}
