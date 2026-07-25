nonisolated enum HostCatalogSubmissionOutcome: Equatable, Sendable {
    case accepted
    case fairnessRejected(FairnessRejection)
    case catalogRejected(HostCatalogServiceError)
}
