import Foundation

nonisolated struct MockSearchTrack: Identifiable, Sendable {
    let id: UUID
    let title: String
    let artist: String
    let isExplicit: Bool
}
