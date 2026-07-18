import Foundation

nonisolated struct SpikeMessage: Codable, Equatable, Sendable {
    nonisolated enum Kind: String, Codable, Sendable {
        case ping
        case acknowledgment
    }

    let kind: Kind
    let text: String
}
