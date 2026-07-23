nonisolated struct FairnessEventID: Hashable, Sendable, Codable {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
