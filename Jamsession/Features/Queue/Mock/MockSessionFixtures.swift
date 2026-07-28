import Foundation

nonisolated enum MockSessionFixtures {
    static let populated: QueueSessionPresentation = {
        let host = QueueSessionPresentation.Participant(
            id: ParticipantID(MockFixtureID.mayaParticipant.uuidString),
            name: "Maya",
            emoji: "🎸",
            colorID: .orange,
            isCurrentUser: false,
            isHost: true,
            status: .connected
        )
        let currentUser = QueueSessionPresentation.Participant(
            id: ParticipantID(MockFixtureID.currentParticipant.uuidString),
            name: "You",
            emoji: "🪩",
            colorID: .purple,
            isCurrentUser: true,
            isHost: false,
            status: .connected
        )
        let friend = QueueSessionPresentation.Participant(
            id: ParticipantID(MockFixtureID.jordanParticipant.uuidString),
            name: "Jordan",
            emoji: "🎧",
            colorID: .green,
            isCurrentUser: false,
            isHost: false,
            status: .connected
        )

        return QueueSessionPresentation(
            sessionName: "Maya’s Jam",
            roomCode: "BEAT",
            participants: [host, currentUser, friend],
            nowPlaying: track(
                id: MockFixtureID.midnightDriveTrack,
                title: "Midnight Drive",
                artist: "The Satellites",
                submitter: host
            ),
            upcoming: [
                track(
                    id: MockFixtureID.goldenHourTrack,
                    title: "Golden Hour",
                    artist: "Paper Planes",
                    submitter: currentUser,
                    canRemove: true,
                    canSkipTurn: true
                ),
                track(
                    id: MockFixtureID.afterglowTrack,
                    title: "Afterglow",
                    artist: "Northbound",
                    submitter: friend,
                    isExplicit: true
                ),
                track(
                    id: MockFixtureID.sideStreetsTrack,
                    title: "Side Streets",
                    artist: "The Satellites",
                    submitter: host
                ),
                track(
                    id: MockFixtureID.electricBlueTrack,
                    title: "Electric Blue",
                    artist: "Night Swim",
                    submitter: currentUser,
                    canRemove: true
                )
            ],
            connectionStatus: .connected
        )
    }()

    static let empty = QueueSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: populated.participants,
        nowPlaying: nil,
        upcoming: [],
        connectionStatus: .connected
    )

    static let solo = QueueSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: [populated.participants[0]],
        nowPlaying: nil,
        upcoming: [],
        connectionStatus: .connected
    )

    static let reconnecting = QueueSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: populated.participants,
        nowPlaying: populated.nowPlaying,
        upcoming: populated.upcoming,
        connectionStatus: .reconnecting
    )

    static let fullSession = QueueSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: populated.participants + [
            participant(id: MockFixtureID.samParticipant, name: "Sam", emoji: "🥁", colorID: .blue),
            participant(id: MockFixtureID.alexParticipant, name: "Alex", emoji: "🎹", colorID: .purple),
            participant(id: MockFixtureID.rileyParticipant, name: "Riley", emoji: "🎤", colorID: .green),
            participant(id: MockFixtureID.caseyParticipant, name: "Casey", emoji: "🎷", colorID: .orange),
            participant(id: MockFixtureID.morganParticipant, name: "Morgan", emoji: "🎻", colorID: .blue)
        ],
        nowPlaying: populated.nowPlaying,
        upcoming: populated.upcoming,
        connectionStatus: .connected
    )

    static let longTitleTrack = track(
        id: MockFixtureID.longTitleTrack,
        title: "Dancing Through the Longest Midnight Drive We’ve Ever Known",
        artist: "The Satellites and the Northern Lights Ensemble",
        submitter: populated.participants[1],
        isExplicit: true,
        canRemove: true
    )

    private static func participant(
        id: UUID,
        name: String,
        emoji: String,
        colorID: ProfileColorID
    ) -> QueueSessionPresentation.Participant {
        QueueSessionPresentation.Participant(
            id: ParticipantID(id.uuidString),
            name: name,
            emoji: emoji,
            colorID: colorID,
            isCurrentUser: false,
            isHost: false,
            status: .connected
        )
    }

    private static func track(
        id: UUID,
        title: String,
        artist: String,
        submitter: QueueSessionPresentation.Participant,
        isExplicit: Bool = false,
        canRemove: Bool = false,
        canSkipTurn: Bool = false
    ) -> QueueSessionPresentation.Track {
        QueueSessionPresentation.Track(
            id: SubmissionID(id.uuidString),
            catalogID: TrackID(id.uuidString),
            title: title,
            artist: artist,
            submitter: submitter,
            isExplicit: isExplicit,
            canRemove: canRemove,
            canSkipTurn: canSkipTurn
        )
    }
}
