import Testing
@testable import Jamsession

struct FairnessSchedulerPropertyTests {
    private let scheduler = FairnessScheduler()

    @Test func generatedEqualSupplyPreservesFIFOAndBalancedCounts() throws {
        for participantCount in 1...8 {
            for supply in 1...8 {
                let participants = (0..<participantCount).map { ParticipantID("P\($0)") }
                var state = RotationState(
                    participants: participants,
                    config: FairnessConfig(maxPendingPerParticipant: 8)
                )
                var eventNumber = 0

                for round in 0..<supply {
                    for participant in participants.reversed() {
                        let name = "\(participant.rawValue)-\(round)"
                        state = try scheduler.applying(
                            FairnessTestSupport.event(eventNumber, .submit(FairnessTestSupport.track(name, by: participant))),
                            to: state
                        )
                        eventNumber += 1
                    }
                }

                let queue = scheduler.upcomingQueue(in: state)
                for participant in participants {
                    let participantTracks = queue.filter { $0.submitterID == participant }.map(\.title)
                    #expect(participantTracks == (0..<supply).map { "\(participant.rawValue)-\($0)" })
                }
                let counts = participants.map { participant in queue.count { $0.submitterID == participant } }
                #expect((counts.max() ?? 0) - (counts.min() ?? 0) <= 1)
                if participantCount > 1 {
                    #expect(zip(queue, queue.dropFirst()).allSatisfy { $0.submitterID != $1.submitterID })
                }
            }
        }
    }

    @Test func generatedUnevenSupplyNeverRepeatsWhileAnotherParticipantIsEligible() throws {
        for seed in 0..<64 {
            let participants = (0..<4).map { ParticipantID("P\($0)") }
            var state = RotationState(
                participants: participants,
                config: FairnessConfig(maxPendingPerParticipant: 12)
            )
            var generator = Generator(state: UInt64(seed + 1))

            for eventNumber in 0..<24 {
                let participant = participants[generator.nextIndex(upperBound: participants.count)]
                if state.pending(for: participant).count < state.config.maxPendingPerParticipant {
                    let name = "S\(seed)-E\(eventNumber)"
                    state = try scheduler.applying(
                        FairnessTestSupport.event(eventNumber, .submit(FairnessTestSupport.track(name, by: participant))),
                        to: state
                    )
                }
            }

            let queue = scheduler.upcomingQueue(in: state)
            for index in queue.indices.dropFirst() where queue[index].submitterID == queue[index - 1].submitterID {
                let repeatedParticipant = queue[index].submitterID
                let remainingBeforeRepeat = queue[index...]
                #expect(!remainingBeforeRepeat.contains { $0.submitterID != repeatedParticipant })
            }
        }
    }

    @Test func lockedOrderOnlyAppendsAndEvaluationIsDeterministic() throws {
        let original = [FairnessTestSupport.a, FairnessTestSupport.b]
        let late = (0..<20).map { ParticipantID("Late-\($0)") }
        var first = RotationState(participants: original)
        var second = RotationState(participants: original)

        for (index, participant) in late.enumerated() {
            let event = FairnessTestSupport.event(index, .addParticipant(participant))
            first = try scheduler.applying(event, to: first)
            second = try scheduler.applying(event, to: second)
            #expect(first.lockedOrder == original + Array(late.prefix(index + 1)))
            #expect(first == second)
        }
    }

    @Test func schedulerCanRunOffTheMainActor() async throws {
        let state = RotationState(participants: [FairnessTestSupport.a])
        let event = FairnessTestSupport.event(
            1,
            .submit(FairnessTestSupport.track("A1", by: FairnessTestSupport.a))
        )

        let title = try await Task.detached {
            let scheduler = FairnessScheduler()
            let updated = try scheduler.applying(event, to: state)
            return scheduler.nextUp(in: updated)?.title
        }.value

        #expect(title == "A1")
    }

    @Test func generatedMixedTransitionsPreserveOrderFairnessAndDeterminism() throws {
        for seed in 0..<48 {
            let participants = (0..<4).map { ParticipantID("P\($0)") }
            var first = RotationState(
                participants: participants,
                config: FairnessConfig(maxPendingPerParticipant: 8)
            )
            var second = first
            var generator = Generator(state: UInt64(seed + 900))
            var eventNumber = 0

            for round in 0..<5 {
                for participant in participants {
                    let track = FairnessTestSupport.track("S\(seed)-P\(participant.rawValue)-R\(round)", by: participant)
                    let event = FairnessTestSupport.event(eventNumber, .submit(track))
                    first = try scheduler.applying(event, to: first)
                    second = try scheduler.applying(event, to: second)
                    eventNumber += 1
                }
            }

            let reconnecting = participants[generator.nextIndex(upperBound: participants.count)]
            try applyToBoth(
                FairnessTestSupport.event(eventNumber, .setStatus(participantID: reconnecting, status: .reconnecting)),
                first: &first,
                second: &second
            )
            eventNumber += 1

            if let next = scheduler.nextUp(in: first) {
                try applyToBoth(
                    FairnessTestSupport.event(eventNumber, .skipOwnTurn(participantID: next.submitterID)),
                    first: &first,
                    second: &second
                )
                eventNumber += 1
            }

            try applyToBoth(
                FairnessTestSupport.event(eventNumber, .advancePlayback),
                first: &first,
                second: &second
            )
            eventNumber += 1

            let removableOwners = participants.filter { !first.pending(for: $0).isEmpty }
            if !removableOwners.isEmpty {
                let owner = removableOwners[generator.nextIndex(upperBound: removableOwners.count)]
                if let submission = first.pending(for: owner).last {
                    try applyToBoth(
                        FairnessTestSupport.event(
                            eventNumber,
                            .removeOwn(submissionID: submission.id, participantID: owner)
                        ),
                        first: &first,
                        second: &second
                    )
                    eventNumber += 1
                }
            }

            try applyToBoth(
                FairnessTestSupport.event(
                    eventNumber,
                    .setStatus(participantID: reconnecting, status: .connected)
                ),
                first: &first,
                second: &second
            )
            eventNumber += 1

            let late = ParticipantID("Late-\(seed)")
            try applyToBoth(
                FairnessTestSupport.event(eventNumber, .addParticipant(late)),
                first: &first,
                second: &second
            )
            eventNumber += 1
            try applyToBoth(
                FairnessTestSupport.event(
                    eventNumber,
                    .submit(FairnessTestSupport.track("Late-track-\(seed)", by: late))
                ),
                first: &first,
                second: &second
            )
            eventNumber += 1

            let gone = participants.first { $0 != first.currentlyPlaying?.submitterID } ?? participants[0]
            try applyToBoth(
                FairnessTestSupport.event(eventNumber, .markGone(gone)),
                first: &first,
                second: &second
            )

            #expect(first == second)
            #expect(first.lockedOrder == participants + [late])
            #expect(first.pending(for: gone).isEmpty)
            expectFairDerivedQueue(scheduler.upcomingQueue(in: first))
        }
    }

    private func applyToBoth(
        _ event: FairnessEvent,
        first: inout RotationState,
        second: inout RotationState
    ) throws {
        first = try scheduler.applying(event, to: first)
        second = try scheduler.applying(event, to: second)
        #expect(first == second)
        expectFairDerivedQueue(scheduler.upcomingQueue(in: first))
    }

    private func expectFairDerivedQueue(_ queue: [QueuedTrack]) {
        for index in queue.indices.dropFirst() where queue[index].submitterID == queue[index - 1].submitterID {
            let repeatedParticipant = queue[index].submitterID
            #expect(!queue[index...].contains { $0.submitterID != repeatedParticipant })
        }
    }

    private struct Generator {
        var state: UInt64

        mutating func nextIndex(upperBound: Int) -> Int {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int(state % UInt64(upperBound))
        }
    }
}
