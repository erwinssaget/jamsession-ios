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
        )
    ]
}
