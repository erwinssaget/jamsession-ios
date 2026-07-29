nonisolated struct HostPlaybackControlsPresentation: Equatable, Sendable {
    let track: QueueSessionPresentation.Track
    let heading: String
    let primaryActionTitle: String
    let primaryActionSystemImage: String
    let skipTitle: String
    let isPrimaryActionDisabled: Bool
    let isSkipDisabled: Bool
}
