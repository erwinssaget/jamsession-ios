#if DEBUG
nonisolated enum DomainQueueHarnessFixtures {
    static let hostID = ParticipantID("domain-host")
    static let guestOneID = ParticipantID("domain-guest-one")
    static let guestTwoID = ParticipantID("domain-guest-two")

    static let participants = [
        SessionParticipant(
            id: hostID,
            displayName: "Maya",
            emoji: "🎸",
            colorID: .orange
        ),
        SessionParticipant(
            id: guestOneID,
            displayName: "Jordan",
            emoji: "🎧",
            colorID: .green
        ),
        SessionParticipant(
            id: guestTwoID,
            displayName: "Sam",
            emoji: "🥁",
            colorID: .blue
        )
    ]

    static let catalog = [
        CatalogTrackSelection(
            id: TrackID("catalog-midnight-drive"),
            title: "Midnight Drive",
            artistName: "The Satellites"
        ),
        CatalogTrackSelection(
            id: TrackID("catalog-golden-hour"),
            title: "Golden Hour",
            artistName: "Paper Planes"
        ),
        CatalogTrackSelection(
            id: TrackID("catalog-afterglow"),
            title: "Afterglow",
            artistName: "Northbound",
            isExplicit: true
        ),
        CatalogTrackSelection(
            id: TrackID("catalog-electric-blue"),
            title: "Electric Blue",
            artistName: "Night Swim"
        ),
        CatalogTrackSelection(
            id: TrackID("catalog-side-streets"),
            title: "Side Streets",
            artistName: "The Satellites"
        )
    ]

    @MainActor
    static func makeSession() -> HostSessionModel {
        let model = HostSessionModel(
            sessionName: "Domain Queue",
            roomCode: "FAIR",
            participants: participants,
            hostID: hostID
        )
        let seeds: [(participantID: ParticipantID, catalogIndex: Int, suffix: String)] = [
            (hostID, 0, "host-one"),
            (guestOneID, 1, "guest-one"),
            (guestTwoID, 2, "guest-two"),
            (hostID, 4, "host-two")
        ]

        for seed in seeds {
            let outcome = model.handle(
                QueueCommand(
                    id: FairnessEventID("seed-event-\(seed.suffix)"),
                    participantID: seed.participantID,
                    action: .submit(
                        selection: catalog[seed.catalogIndex],
                        submissionID: SubmissionID("seed-\(seed.suffix)")
                    )
                )
            )
            precondition(outcome == .accepted)
        }
        model.dismissLastCommandOutcome()
        return model
    }
}
#endif
