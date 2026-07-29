nonisolated enum HostPlaybackStatus: Equatable, Sendable {
    case stopped
    case playing
    case paused
    case interrupted
    case seeking

    var isActivelyPlaying: Bool {
        switch self {
        case .playing, .seeking:
            true
        case .stopped, .paused, .interrupted:
            false
        }
    }
}
