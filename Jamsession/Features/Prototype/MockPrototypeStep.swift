enum MockPrototypeStep: Equatable {
    case welcome
    case profile(SessionRole)
    case hostLobby
    case discovery
    case awaitingApproval
    case joinedQueue
    case lifecycle
}
