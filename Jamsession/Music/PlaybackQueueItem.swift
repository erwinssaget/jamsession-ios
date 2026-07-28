nonisolated struct PlaybackQueueItem: Equatable, Hashable, Identifiable, Sendable {
    let id: SubmissionID
    let trackID: TrackID
}
