nonisolated enum ParticipantStatus: Sendable, Equatable, Codable {
    case connected
    case reconnecting
    case gone
    case removed
}
