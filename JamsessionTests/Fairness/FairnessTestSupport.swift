@testable import Jamsession

enum FairnessTestSupport {
    static let a = ParticipantID("A")
    static let b = ParticipantID("B")
    static let c = ParticipantID("C")

    static func track(
        _ name: String,
        by participantID: ParticipantID,
        trackID: String? = nil
    ) -> QueuedTrack {
        QueuedTrack(
            id: SubmissionID(name),
            trackID: TrackID(trackID ?? name),
            submitterID: participantID,
            title: name,
            artistName: "Artist"
        )
    }

    static func event(_ number: Int, _ action: FairnessEvent.Action) -> FairnessEvent {
        FairnessEvent(id: FairnessEventID("event-\(number)"), action: action)
    }

    static func state(
        participants: [ParticipantID] = [a, b, c],
        tracks: [QueuedTrack]
    ) throws -> RotationState {
        let scheduler = FairnessScheduler()
        var state = RotationState(participants: participants)
        for (index, track) in tracks.enumerated() {
            state = try scheduler.applyingAccepted(event(index, .submit(track)), to: state)
        }
        return state
    }
}
