import Testing
@testable import Jamsession

struct PlaybackTransitionDeduplicatorTests {
    private let firstID = SubmissionID("first")
    private let secondID = SubmissionID("second")

    @Test
    func initialStoppedEntryDoesNotAdvanceUntilPlaybackStarts() {
        var deduplicator = PlaybackTransitionDeduplicator()

        #expect(
            deduplicator.transition(
                for: observation(firstID, status: .stopped),
                canonicalCurrentItemID: nil,
                canonicalNextItemID: firstID
            ) == nil
        )
        #expect(
            deduplicator.transition(
                for: observation(firstID, status: .playing),
                canonicalCurrentItemID: nil,
                canonicalNextItemID: firstID
            ) == .started(firstID)
        )
    }

    @Test
    func repeatedStartCallbacksEmitOneStableTransition() {
        var deduplicator = PlaybackTransitionDeduplicator()
        _ = deduplicator.transition(
            for: observation(firstID, status: .stopped),
            canonicalCurrentItemID: nil,
            canonicalNextItemID: firstID
        )

        #expect(
            deduplicator.transition(
                for: observation(firstID, status: .playing),
                canonicalCurrentItemID: nil,
                canonicalNextItemID: firstID
            ) == .started(firstID)
        )
        #expect(
            deduplicator.transition(
                for: observation(firstID, status: .playing),
                canonicalCurrentItemID: nil,
                canonicalNextItemID: firstID
            ) == nil
        )
    }

    @Test
    func completionOrSkipEmitsOnceWhenCurrentEntryChanges() {
        var deduplicator = PlaybackTransitionDeduplicator()
        _ = deduplicator.transition(
            for: observation(firstID, status: .playing),
            canonicalCurrentItemID: firstID,
            canonicalNextItemID: secondID
        )

        #expect(
            deduplicator.transition(
                for: observation(secondID, status: .playing),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == .departed(firstID)
        )
        #expect(
            deduplicator.transition(
                for: observation(secondID, status: .playing),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == nil
        )
    }

    @Test
    func lastEntryCompletionEmitsOnceForEmptyPlayerQueue() {
        var deduplicator = PlaybackTransitionDeduplicator()
        _ = deduplicator.transition(
            for: observation(firstID, status: .playing),
            canonicalCurrentItemID: firstID,
            canonicalNextItemID: nil
        )
        let empty = HostPlaybackObservation(currentItem: .none, status: .stopped)

        #expect(
            deduplicator.transition(
                for: empty,
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: nil
            ) == .departed(firstID)
        )
        #expect(
            deduplicator.transition(
                for: empty,
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: nil
            ) == nil
        )
    }

    @Test
    func transientNilCurrentWaitsForTheExpectedNextEntry() {
        var deduplicator = PlaybackTransitionDeduplicator()
        _ = deduplicator.transition(
            for: observation(firstID, status: .playing),
            canonicalCurrentItemID: firstID,
            canonicalNextItemID: secondID
        )

        #expect(
            deduplicator.transition(
                for: HostPlaybackObservation(currentItem: .none, status: .stopped),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == nil
        )
        #expect(
            deduplicator.transition(
                for: observation(secondID, status: .playing),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == .departed(firstID)
        )
    }

    @Test
    func pauseResumeAndUnmanagedEntriesDoNotAdvance() {
        var deduplicator = PlaybackTransitionDeduplicator()
        _ = deduplicator.transition(
            for: observation(firstID, status: .playing),
            canonicalCurrentItemID: firstID,
            canonicalNextItemID: secondID
        )

        #expect(
            deduplicator.transition(
                for: observation(firstID, status: .paused),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == nil
        )
        #expect(
            deduplicator.transition(
                for: observation(firstID, status: .playing),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == nil
        )
        #expect(
            deduplicator.transition(
                for: HostPlaybackObservation(
                    currentItem: .unmanaged,
                    status: .playing
                ),
                canonicalCurrentItemID: firstID,
                canonicalNextItemID: secondID
            ) == nil
        )
    }

    private func observation(
        _ itemID: SubmissionID,
        status: HostPlaybackStatus
    ) -> HostPlaybackObservation {
        HostPlaybackObservation(
            currentItem: .managed(itemID),
            status: status
        )
    }
}
