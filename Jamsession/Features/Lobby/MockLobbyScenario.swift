nonisolated enum MockLobbyScenario: String, CaseIterable, Identifiable {
    case hostLobby
    case approvalRequest
    case discovery
    case noNearbySessions
    case awaitingApproval
    case roomFull
    case rejected

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .hostLobby:
            "mockLobby.scenario.hostLobby"
        case .approvalRequest:
            "mockLobby.scenario.approvalRequest"
        case .discovery:
            "mockLobby.scenario.discovery"
        case .noNearbySessions:
            "mockLobby.scenario.noNearby"
        case .awaitingApproval:
            "mockLobby.scenario.awaitingApproval"
        case .roomFull:
            "mockLobby.scenario.roomFull"
        case .rejected:
            "mockLobby.scenario.rejected"
        }
    }
}
