import Foundation

nonisolated enum MockSearchFixtures {
    static let tracks = [
        MockSearchTrack(
            id: MockFixtureID.goldenHourTrack,
            title: "Golden Hour",
            artist: "Paper Planes",
            isExplicit: false
        ),
        MockSearchTrack(
            id: MockFixtureID.afterglowTrack,
            title: "Afterglow",
            artist: "Northbound",
            isExplicit: true
        ),
        MockSearchTrack(
            id: MockFixtureID.electricBlueTrack,
            title: "Electric Blue",
            artist: "Night Swim",
            isExplicit: false
        ),
        longTitleTrack
    ]

    static let longTitleTrack = MockSearchTrack(
        id: MockFixtureID.longTitleTrack,
        title: "Dancing Through the Longest Midnight Drive We’ve Ever Known",
        artist: "The Satellites and the Northern Lights Ensemble",
        isExplicit: true
    )
}
