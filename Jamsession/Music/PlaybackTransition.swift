nonisolated struct PlaybackTransition: Equatable, Sendable {
    let commandID: FairnessEventID

    static func started(_ itemID: SubmissionID) -> PlaybackTransition {
        PlaybackTransition(
            commandID: FairnessEventID("playback-started-\(itemID.rawValue)")
        )
    }

    static func departed(_ itemID: SubmissionID) -> PlaybackTransition {
        PlaybackTransition(
            commandID: FairnessEventID("playback-departed-\(itemID.rawValue)")
        )
    }
}
