nonisolated enum HostPlaybackError: Error, Equatable, Sendable {
    case authorizationRequired
    case subscriptionRequired
    case offline
    case trackUnavailable
    case queueChanged
    case unavailable
}
