nonisolated struct QueuedTrack: Sendable, Equatable, Codable, Identifiable {
    let id: SubmissionID
    let trackID: TrackID
    let submitterID: ParticipantID
    let title: String
    let artistName: String
    let isExplicit: Bool

    init(
        id: SubmissionID,
        trackID: TrackID,
        submitterID: ParticipantID,
        title: String,
        artistName: String,
        isExplicit: Bool = false
    ) {
        self.id = id
        self.trackID = trackID
        self.submitterID = submitterID
        self.title = title
        self.artistName = artistName
        self.isExplicit = isExplicit
    }
}
