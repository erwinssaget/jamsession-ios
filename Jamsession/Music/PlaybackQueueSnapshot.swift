nonisolated struct PlaybackQueueSnapshot: Equatable, Sendable {
    let items: [PlaybackQueueItem]
    let protectedItemID: SubmissionID?

    init(
        items: [PlaybackQueueItem],
        protectedItemID: SubmissionID? = nil
    ) {
        self.items = items
        self.protectedItemID = protectedItemID
    }
}
