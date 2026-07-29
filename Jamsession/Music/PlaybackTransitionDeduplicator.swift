nonisolated struct PlaybackTransitionDeduplicator: Sendable {
    private var previousObservation: HostPlaybackObservation?
    private var emittedCommandIDs: Set<FairnessEventID> = []

    mutating func transition(
        for observation: HostPlaybackObservation,
        canonicalCurrentItemID: SubmissionID?,
        canonicalNextItemID: SubmissionID?
    ) -> PlaybackTransition? {
        guard observation.currentItem != .unmanaged else {
            previousObservation = observation
            return nil
        }

        if let canonicalCurrentItemID {
            guard observation.currentItem != .managed(canonicalCurrentItemID),
                  previousObservation?.currentItem == .managed(canonicalCurrentItemID) else {
                previousObservation = observation
                return nil
            }
            if case .managed(let itemID) = observation.currentItem {
                guard itemID == canonicalNextItemID else {
                    previousObservation = observation
                    return nil
                }
            } else if observation.currentItem == .none,
                      canonicalNextItemID != nil {
                // Some player callbacks briefly clear currentEntry before publishing
                // the actual next managed entry. Retain the departed item so that
                // later entry can still produce exactly one transition.
                return nil
            }
            previousObservation = observation
            return emit(.departed(canonicalCurrentItemID))
        }

        previousObservation = observation
        guard observation.status.isActivelyPlaying,
              let itemID = observation.currentItem.managedID,
              itemID == canonicalNextItemID else {
            return nil
        }
        return emit(.started(itemID))
    }

    private mutating func emit(
        _ transition: PlaybackTransition
    ) -> PlaybackTransition? {
        emittedCommandIDs.insert(transition.commandID).inserted
            ? transition
            : nil
    }
}
