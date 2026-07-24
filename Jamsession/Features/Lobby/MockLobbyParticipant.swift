import Foundation

nonisolated struct MockLobbyParticipant: Identifiable, Sendable {
    let id: UUID
    let name: String
    let emoji: String
    let detailKey: String
}
