nonisolated struct ParticipantID: Hashable, Sendable, Codable {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
