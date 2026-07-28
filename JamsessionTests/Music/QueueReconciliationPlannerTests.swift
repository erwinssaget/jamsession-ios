import Testing
@testable import Jamsession

struct QueueReconciliationPlannerTests {
    private let planner = QueueReconciliationPlanner()

    @Test
    func identicalQueueNeedsNoOperations() throws {
        let items = [item("A"), item("B")]

        let plan = try planner.plan(
            from: PlaybackQueueSnapshot(items: items),
            to: items
        )

        #expect(plan.operations.isEmpty)
    }

    @Test
    func insertsOnlyTheMissingTailEntry() throws {
        let a = item("A")
        let b = item("B")

        let plan = try planner.plan(
            from: PlaybackQueueSnapshot(items: [a]),
            to: [a, b]
        )

        #expect(plan.operations == [.insert(b, at: 1)])
    }

    @Test
    func removesAnEntryWithoutMovingTheFollowingEntry() throws {
        let a = item("A")
        let b = item("B")
        let c = item("C")

        let plan = try planner.plan(
            from: PlaybackQueueSnapshot(items: [a, b, c]),
            to: [a, c]
        )

        #expect(plan.operations == [.remove(b.id, at: 1)])
    }

    @Test
    func movesAnExistingEntryWhenBothEntriesRemain() throws {
        let a = item("A")
        let b = item("B")
        let c = item("C")

        let plan = try planner.plan(
            from: PlaybackQueueSnapshot(items: [a, b, c]),
            to: [a, c, b]
        )

        #expect(plan.operations == [.move(c.id, from: 2, to: 1)])
    }

    @Test
    func combinesRemovalMoveAndInsertionDeterministically() throws {
        let a = item("A")
        let b = item("B")
        let c = item("C")
        let d = item("D")
        let e = item("E")

        let plan = try planner.plan(
            from: PlaybackQueueSnapshot(items: [a, b, c, d]),
            to: [a, d, c, e]
        )

        #expect(
            plan.operations == [
                .remove(b.id, at: 1),
                .move(d.id, from: 2, to: 1),
                .insert(e, at: 3)
            ]
        )
    }

    @Test
    func protectedCurrentEntryStaysAtTheFront() throws {
        let current = item("Current")
        let a = item("A")
        let b = item("B")

        let plan = try planner.plan(
            from: PlaybackQueueSnapshot(
                items: [current, a, b],
                protectedItemID: current.id
            ),
            to: [current, b, a]
        )

        #expect(plan.operations == [.move(b.id, from: 2, to: 1)])
    }

    @Test
    func protectedCurrentEntryCannotBeRemovedOrReplaced() {
        let current = item("Current")
        let replacement = item("Replacement")

        #expect(throws: QueueReconciliationPlanningError.protectedItemMismatch) {
            try planner.plan(
                from: PlaybackQueueSnapshot(
                    items: [current],
                    protectedItemID: current.id
                ),
                to: [replacement]
            )
        }
    }

    @Test
    func duplicateSubmissionIdentityIsRejectedBeforePlanning() {
        let a = item("A")
        let duplicateIdentity = PlaybackQueueItem(
            id: a.id,
            trackID: TrackID("different-track")
        )

        #expect(throws: QueueReconciliationPlanningError.duplicateItemIdentity) {
            try planner.plan(
                from: PlaybackQueueSnapshot(items: []),
                to: [a, duplicateIdentity]
            )
        }
    }

    private func item(_ name: String) -> PlaybackQueueItem {
        PlaybackQueueItem(
            id: SubmissionID("submission-\(name)"),
            trackID: TrackID("track-\(name)")
        )
    }
}
