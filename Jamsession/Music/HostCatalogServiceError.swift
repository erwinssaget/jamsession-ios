nonisolated enum HostCatalogServiceError: Error, Equatable, Sendable {
    case authorizationRequired
    case subscriptionRequired
    case offline
    case trackUnavailable
    case unavailable
}
