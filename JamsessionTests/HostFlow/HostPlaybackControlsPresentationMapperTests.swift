import Testing
@testable import Jamsession

struct HostPlaybackControlsPresentationMapperTests {
    @Test
    func stoppedPendingTrackMapsToReadyPlayControlsWithoutSkip() throws {
        let queue = presentation(nowPlaying: nil, upcoming: [track("A")])

        let controls = try #require(
            HostPlaybackControlsPresentationMapper.map(
                queue: queue,
                currentItemID: SubmissionID("A"),
                playbackStatus: .stopped,
                playerState: .ready,
                isControlRequestInFlight: false
            )
        )

        #expect(controls.heading == "Ready to Play")
        #expect(controls.primaryActionTitle == "Play")
        #expect(!controls.isPrimaryActionDisabled)
        #expect(controls.isSkipDisabled)
    }

    @Test
    func playingCanonicalTrackMapsToPauseAndEnabledSkip() throws {
        let queue = presentation(nowPlaying: track("A"), upcoming: [])

        let controls = try #require(
            HostPlaybackControlsPresentationMapper.map(
                queue: queue,
                currentItemID: SubmissionID("A"),
                playbackStatus: .playing,
                playerState: .ready,
                isControlRequestInFlight: false
            )
        )

        #expect(controls.heading == "Now Playing")
        #expect(controls.primaryActionTitle == "Pause")
        #expect(!controls.isSkipDisabled)
    }

    @Test
    func failureAndInFlightRequestDisableControls() throws {
        let queue = presentation(nowPlaying: track("A"), upcoming: [])

        let failed = try #require(
            HostPlaybackControlsPresentationMapper.map(
                queue: queue,
                currentItemID: SubmissionID("A"),
                playbackStatus: .paused,
                playerState: .failed(.offline),
                isControlRequestInFlight: false
            )
        )
        let inFlight = try #require(
            HostPlaybackControlsPresentationMapper.map(
                queue: queue,
                currentItemID: SubmissionID("A"),
                playbackStatus: .paused,
                playerState: .ready,
                isControlRequestInFlight: true
            )
        )

        #expect(failed.isPrimaryActionDisabled)
        #expect(failed.isSkipDisabled)
        #expect(inFlight.isPrimaryActionDisabled)
        #expect(inFlight.isSkipDisabled)
    }

    @Test
    func emptyOrUnmatchedPlayerItemHasNoControls() {
        let empty = presentation(nowPlaying: nil, upcoming: [])
        let queue = presentation(nowPlaying: nil, upcoming: [track("A")])

        #expect(
            HostPlaybackControlsPresentationMapper.map(
                queue: empty,
                currentItemID: nil,
                playbackStatus: .stopped,
                playerState: .idle,
                isControlRequestInFlight: false
            ) == nil
        )
        #expect(
            HostPlaybackControlsPresentationMapper.map(
                queue: queue,
                currentItemID: SubmissionID("unknown"),
                playbackStatus: .playing,
                playerState: .ready,
                isControlRequestInFlight: false
            ) == nil
        )
    }

    private func presentation(
        nowPlaying: QueueSessionPresentation.Track?,
        upcoming: [QueueSessionPresentation.Track]
    ) -> QueueSessionPresentation {
        QueueSessionPresentation(
            sessionName: "Test",
            roomCode: "TEST",
            participants: [participant],
            nowPlaying: nowPlaying,
            upcoming: upcoming,
            connectionStatus: .connected
        )
    }

    private func track(_ id: String) -> QueueSessionPresentation.Track {
        QueueSessionPresentation.Track(
            id: SubmissionID(id),
            catalogID: TrackID("track-\(id)"),
            title: "Song \(id)",
            artist: "Artist",
            submitter: participant,
            isExplicit: false,
            canRemove: true,
            canSkipTurn: false
        )
    }

    private var participant: QueueSessionPresentation.Participant {
        QueueSessionPresentation.Participant(
            id: ParticipantID("host"),
            name: "Host",
            emoji: "🎸",
            colorID: .orange,
            isCurrentUser: true,
            isHost: true,
            status: .connected
        )
    }
}
