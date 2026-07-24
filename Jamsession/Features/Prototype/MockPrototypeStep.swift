enum MockPrototypeStep: Equatable {
    case welcome
    case profile(MockEntryRole)
    case hostLobby
    case discovery
    case awaitingApproval
    case joinedQueue
    case lifecycle
}
