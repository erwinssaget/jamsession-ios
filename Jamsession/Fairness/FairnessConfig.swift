nonisolated struct FairnessConfig: Sendable, Equatable, Codable {
    var maxPendingPerParticipant: Int
    var blocksPendingDuplicates: Bool

    init(
        maxPendingPerParticipant: Int = 3,
        blocksPendingDuplicates: Bool = true
    ) {
        precondition(maxPendingPerParticipant > 0)
        self.maxPendingPerParticipant = maxPendingPerParticipant
        self.blocksPendingDuplicates = blocksPendingDuplicates
    }
}
