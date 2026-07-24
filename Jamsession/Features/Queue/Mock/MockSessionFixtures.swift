import Foundation

nonisolated enum MockSessionFixtures {
    static let populated: MockSessionPresentation = {
        let host = MockSessionPresentation.Participant(
            id: MockFixtureID.mayaParticipant,
            name: "Maya",
            emoji: "🎸",
            color: .orange,
            isCurrentUser: false
        )
        let currentUser = MockSessionPresentation.Participant(
            id: MockFixtureID.currentParticipant,
            name: "You",
            emoji: "🪩",
            color: .purple,
            isCurrentUser: true
        )
        let friend = MockSessionPresentation.Participant(
            id: MockFixtureID.jordanParticipant,
            name: "Jordan",
            emoji: "🎧",
            color: .green,
            isCurrentUser: false
        )

        return MockSessionPresentation(
            sessionName: "Maya’s Jam",
            roomCode: "BEAT",
            participants: [host, currentUser, friend],
            nowPlaying: .init(
                id: MockFixtureID.midnightDriveTrack,
                title: "Midnight Drive",
                artist: "The Satellites",
                submitter: host,
                isExplicit: false
            ),
            upcoming: [
                .init(
                    id: MockFixtureID.goldenHourTrack,
                    title: "Golden Hour",
                    artist: "Paper Planes",
                    submitter: currentUser,
                    isExplicit: false
                ),
                .init(
                    id: MockFixtureID.afterglowTrack,
                    title: "Afterglow",
                    artist: "Northbound",
                    submitter: friend,
                    isExplicit: true
                ),
                .init(
                    id: MockFixtureID.sideStreetsTrack,
                    title: "Side Streets",
                    artist: "The Satellites",
                    submitter: host,
                    isExplicit: false
                ),
                .init(
                    id: MockFixtureID.electricBlueTrack,
                    title: "Electric Blue",
                    artist: "Night Swim",
                    submitter: currentUser,
                    isExplicit: false
                )
            ],
            connectionStatus: .connected
        )
    }()

    static let empty = MockSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: populated.participants,
        nowPlaying: nil,
        upcoming: [],
        connectionStatus: .connected
    )

    static let reconnecting = MockSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: populated.participants,
        nowPlaying: populated.nowPlaying,
        upcoming: populated.upcoming,
        connectionStatus: .reconnecting
    )

    static let fullSession = MockSessionPresentation(
        sessionName: "Maya’s Jam",
        roomCode: "BEAT",
        participants: populated.participants + [
            .init(
                id: MockFixtureID.samParticipant,
                name: "Sam",
                emoji: "🥁",
                color: .blue,
                isCurrentUser: false
            ),
            .init(
                id: MockFixtureID.alexParticipant,
                name: "Alex",
                emoji: "🎹",
                color: .purple,
                isCurrentUser: false
            ),
            .init(
                id: MockFixtureID.rileyParticipant,
                name: "Riley",
                emoji: "🎤",
                color: .green,
                isCurrentUser: false
            ),
            .init(
                id: MockFixtureID.caseyParticipant,
                name: "Casey",
                emoji: "🎷",
                color: .orange,
                isCurrentUser: false
            ),
            .init(
                id: MockFixtureID.morganParticipant,
                name: "Morgan",
                emoji: "🎻",
                color: .blue,
                isCurrentUser: false
            )
        ],
        nowPlaying: populated.nowPlaying,
        upcoming: populated.upcoming,
        connectionStatus: .connected
    )

    static let longTitleTrack = MockSessionPresentation.Track(
        id: MockFixtureID.longTitleTrack,
        title: "Dancing Through the Longest Midnight Drive We’ve Ever Known",
        artist: "The Satellites and the Northern Lights Ensemble",
        submitter: populated.participants[1],
        isExplicit: true
    )
}
