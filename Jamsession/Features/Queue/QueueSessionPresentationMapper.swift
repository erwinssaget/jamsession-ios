import Foundation

nonisolated enum QueueSessionPresentationMapper {
    static func map(
        sessionName: String,
        roomCode: String,
        participants: [SessionParticipant],
        hostID: ParticipantID,
        viewerID: ParticipantID,
        state: RotationState,
        scheduler: FairnessScheduler
    ) -> QueueSessionPresentation {
        let participantPresentations = participants.map { participant in
            presentation(
                for: participant,
                hostID: hostID,
                viewerID: viewerID,
                status: state.status(for: participant.id) ?? .gone
            )
        }
        let participantsByID = Dictionary(
            uniqueKeysWithValues: participantPresentations.map { ($0.id, $0) }
        )
        let viewerIsHost = viewerID == hostID
        let upcoming = scheduler.upcomingQueue(in: state)

        return QueueSessionPresentation(
            sessionName: sessionName,
            roomCode: roomCode,
            participants: participantPresentations,
            nowPlaying: state.currentlyPlaying.map { track in
                trackPresentation(
                    track,
                    participantsByID: participantsByID,
                    viewerID: viewerID,
                    viewerIsHost: viewerIsHost,
                    canSkipTurn: false
                )
            },
            upcoming: upcoming.enumerated().map { index, track in
                trackPresentation(
                    track,
                    participantsByID: participantsByID,
                    viewerID: viewerID,
                    viewerIsHost: viewerIsHost,
                    canSkipTurn: index == 0
                )
            },
            connectionStatus: state.status(for: viewerID) == .reconnecting
                ? .reconnecting
                : .connected
        )
    }

    private static func presentation(
        for participant: SessionParticipant,
        hostID: ParticipantID,
        viewerID: ParticipantID,
        status: ParticipantStatus
    ) -> QueueSessionPresentation.Participant {
        QueueSessionPresentation.Participant(
            id: participant.id,
            name: participant.displayName,
            emoji: participant.emoji,
            colorID: participant.colorID,
            isCurrentUser: participant.id == viewerID,
            isHost: participant.id == hostID,
            status: status
        )
    }

    private static func trackPresentation(
        _ track: QueuedTrack,
        participantsByID: [ParticipantID: QueueSessionPresentation.Participant],
        viewerID: ParticipantID,
        viewerIsHost: Bool,
        canSkipTurn: Bool
    ) -> QueueSessionPresentation.Track {
        let submitter = participantsByID[track.submitterID] ?? unknownParticipant(
            id: track.submitterID
        )

        return QueueSessionPresentation.Track(
            id: track.id,
            catalogID: track.trackID,
            title: track.title,
            artist: track.artistName,
            submitter: submitter,
            isExplicit: track.isExplicit,
            canRemove: viewerIsHost || track.submitterID == viewerID,
            canSkipTurn: canSkipTurn && (viewerIsHost || track.submitterID == viewerID)
        )
    }

    private static func unknownParticipant(
        id: ParticipantID
    ) -> QueueSessionPresentation.Participant {
        QueueSessionPresentation.Participant(
            id: id,
            name: String(localized: "queue.participant.unknown", defaultValue: "Unknown participant"),
            emoji: "?",
            colorID: .blue,
            isCurrentUser: false,
            isHost: false,
            status: .gone
        )
    }
}
