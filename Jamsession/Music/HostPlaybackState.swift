nonisolated enum HostPlaybackState: Equatable, Sendable {
    case idle
    case reconciling
    case ready
    case failed(HostPlaybackError)
}
