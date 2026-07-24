import Foundation

nonisolated struct MockSessionPresentation: Equatable, Sendable {
    let sessionName: String
    let roomCode: String
    let participants: [Participant]
    let nowPlaying: Track?
    let upcoming: [Track]
    let connectionStatus: ConnectionStatus

    struct Participant: Equatable, Identifiable, Sendable {
        let id: UUID
        let name: String
        let emoji: String
        let color: ParticipantColor
        let isCurrentUser: Bool
    }

    struct Track: Equatable, Identifiable, Sendable {
        let id: UUID
        let title: String
        let artist: String
        let submitter: Participant
        let isExplicit: Bool
    }

    enum ConnectionStatus: Equatable, Sendable {
        case connected
        case reconnecting
    }

    enum ParticipantColor: Equatable, Sendable {
        case blue
        case green
        case orange
        case purple
    }
}
