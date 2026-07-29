import Foundation

nonisolated enum HostPlaybackControlsPresentationMapper {
    static func map(
        queue: QueueSessionPresentation,
        currentItemID: SubmissionID?,
        playbackStatus: HostPlaybackStatus,
        playerState: HostPlaybackState,
        isControlRequestInFlight: Bool
    ) -> HostPlaybackControlsPresentation? {
        guard let currentItemID,
              let track = ([queue.nowPlaying].compactMap(\.self) + queue.upcoming)
                .first(where: { $0.id == currentItemID }) else {
            return nil
        }

        let isCurrentTrack = queue.nowPlaying?.id == currentItemID
        let isPlaying = playbackStatus.isActivelyPlaying
        let controlsUnavailable: Bool
        switch playerState {
        case .reconciling, .failed:
            controlsUnavailable = true
        case .idle, .ready:
            controlsUnavailable = false
        }

        return HostPlaybackControlsPresentation(
            track: track,
            heading: isCurrentTrack
                ? String(localized: "host.playback.nowPlaying", defaultValue: "Now Playing")
                : String(localized: "host.playback.ready", defaultValue: "Ready to Play"),
            primaryActionTitle: isPlaying
                ? String(localized: "host.playback.pause", defaultValue: "Pause")
                : String(localized: "host.playback.play", defaultValue: "Play"),
            primaryActionSystemImage: isPlaying ? "pause.fill" : "play.fill",
            skipTitle: String(
                localized: "host.playback.skipCurrent",
                defaultValue: "Skip Current Song"
            ),
            isPrimaryActionDisabled: controlsUnavailable || isControlRequestInFlight,
            isSkipDisabled: controlsUnavailable
                || isControlRequestInFlight
                || !isCurrentTrack
        )
    }
}
